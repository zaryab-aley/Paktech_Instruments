# Data Factory exports

ARM files are the supplied export. Individual JSON resources are extracted without changing their properties. These files are intended for review and adaptation, not a one-click deployment of the complete platform. See ../docs/export_review.md before deployment.

Pipelines: Main_Pipeline (complete flow), Recover_Gold (Gold only), Test_Failure_Alert (now a Wait activity after recovery), Test_Missing_Source (now the corrected source URL). The diagnostic settings, Log Analytics workspace, Azure Monitor metric alert and email action group are separate Azure resources and are not provisioned by this export.

The root ARM and linked templates are alternate forms. Supply the blank secure account-key parameter privately. Other values are environment-specific. Do not modify raw source paths without updating the manifest and dataset configuration.
