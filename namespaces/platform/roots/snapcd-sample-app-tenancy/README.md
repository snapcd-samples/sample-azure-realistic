# snapcd-sample-app-tenancy

Creates the Snap CD side of the `app` namespace: the namespace itself (hooks, backend flags, inputs and extra files, with `azurerm` provider registrations off), the `app` state store, the app runner's supply to the namespace, and the role assignments that confine the app team and the app runner to it.

Runs as the platform module `sample_app_tenancy_snapcd` on the platform runner. The `snapcd` provider takes its credentials from the runner's `SNAPCD_CLIENT_ID` and `SNAPCD_CLIENT_SECRET`, so the platform runner's service principal must be allowed to create namespaces, state stores and role assignments (Organization Owner).

| Input | Source |
|---|---|
| `stack_id` | the platform namespace's `StackId` definition |
| `namespace_name`, `organization_id`, `snapcd_server_url_from_runner`, `app_runner_name`, `app_runner_client_id`, `app_team_client_id` | literals set by `namespaces/platform` |
| `location`, `subscription_id`, `tenant_id`, `administrator_object_id` | the platform namespace's literal inputs |

Outputs `namespace_id`, `namespace_name` and `state_store_id`.
