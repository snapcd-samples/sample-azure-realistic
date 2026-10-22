using System.Buffers.Text;
using System.Net;
using System.Text.Json;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var sqlConnectionString = builder.Configuration["SQL_CONNECTION_STRING"];
var keyVaultUrl = builder.Configuration["KEY_VAULT_URL"];
var demoSecretName = builder.Configuration["DEMO_SECRET_NAME"];

var credential = new DefaultAzureCredential();

app.MapGet("/healthz", () => Results.Ok("ok"));

app.MapGet("/", async (CancellationToken ct) =>
{
    var checks = new[]
    {
        await Run("Identity", () => CheckIdentity(credential, ct)),
        await Run("Azure SQL", () => CheckSql(sqlConnectionString, credential, ct)),
        await Run("Key Vault", () => CheckKeyVault(keyVaultUrl, demoSecretName, credential, ct)),
    };
    return Results.Content(Render(checks), "text/html; charset=utf-8");
});

app.Run();

static async Task<Check> Run(string name, Func<Task<string>> check)
{
    try
    {
        return new Check(name, true, await check());
    }
    catch (Exception ex)
    {
        return new Check(name, false, $"{ex.GetType().Name}: {ex.Message}");
    }
}

static async Task<string> CheckIdentity(TokenCredential credential, CancellationToken ct)
{
    var token = await credential.GetTokenAsync(new TokenRequestContext(["https://vault.azure.net/.default"]), ct);
    var payload = Base64Url.DecodeFromChars(token.Token.Split('.')[1]);
    using var claims = JsonDocument.Parse(payload);
    var appId = claims.RootElement.TryGetProperty("appid", out var a) ? a.GetString() : "?";
    var objectId = claims.RootElement.TryGetProperty("oid", out var o) ? o.GetString() : "?";
    return $"client id {appId}, object id {objectId}";
}

static async Task<string> CheckSql(string? connectionString, TokenCredential credential, CancellationToken ct)
{
    if (string.IsNullOrEmpty(connectionString))
        throw new InvalidOperationException("SQL_CONNECTION_STRING is not set");

    await using var connection = new SqlConnection(connectionString)
    {
        AccessTokenCallback = async (_, token) =>
        {
            var accessToken = await credential.GetTokenAsync(new TokenRequestContext(["https://database.windows.net/.default"]), token);
            return new SqlAuthenticationToken(accessToken.Token, accessToken.ExpiresOn);
        },
    };
    await connection.OpenAsync(ct);

    await using var command = connection.CreateCommand();
    command.CommandText = """
        IF OBJECT_ID('dbo.visits') IS NULL
            CREATE TABLE dbo.visits (id INT IDENTITY PRIMARY KEY, visited_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME());
        INSERT INTO dbo.visits DEFAULT VALUES;
        SELECT COUNT(*) FROM dbo.visits;
        """;
    var visits = (int)(await command.ExecuteScalarAsync(ct))!;
    return $"{connection.DataSource} / {connection.Database}: {visits} visits";
}

static async Task<string> CheckKeyVault(string? vaultUrl, string? secretName, TokenCredential credential, CancellationToken ct)
{
    if (string.IsNullOrEmpty(vaultUrl) || string.IsNullOrEmpty(secretName))
        throw new InvalidOperationException("KEY_VAULT_URL and DEMO_SECRET_NAME must be set");

    var client = new SecretClient(new Uri(vaultUrl), credential);
    KeyVaultSecret secret = await client.GetSecretAsync(secretName, cancellationToken: ct);
    return $"{secretName}: \"{secret.Value}\"";
}

static string Render(IEnumerable<Check> checks)
{
    var rows = string.Join("\n", checks.Select(c =>
        $"<tr><td>{(c.Ok ? "&#x2705;" : "&#x274C;")}</td><td>{WebUtility.HtmlEncode(c.Name)}</td><td><code>{WebUtility.HtmlEncode(c.Detail)}</code></td></tr>"));
    return $$"""
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>sample-app</title>
          <style>
            body { font-family: system-ui, sans-serif; margin: 2rem; }
            td { padding: 0.4rem 0.8rem; vertical-align: top; }
            code { white-space: pre-wrap; word-break: break-word; }
          </style>
        </head>
        <body>
          <h1>sample-app</h1>
          <table>
        {{rows}}
          </table>
        </body>
        </html>
        """;
}

record Check(string Name, bool Ok, string Detail);
