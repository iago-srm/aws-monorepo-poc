# Commands
- `terraform validate` para dizer se o script é válido
- `terraform fmt` formata o arquivo .tf
- `terraform plan -out tfplan.out` gera um arquivo de plan a partir do .tf
- `terraform apply tfplan.out` aplica o plan gerado. Passar --auto-aprove pra não ter que aprovar o plan antes de dar o apply.

- `terraform plan -out staging-plan.out -var-file="staging.tfvars"`
- `terraform plan -out prod-plan.out -var-file="prod.tfvars"`

Arquivo variables.tf é necessário para definir as variáveis (editor usa isso pra sugestões), e os *.tfvars definem os valores.

Para acessar output variables
`terraform output var_name`

