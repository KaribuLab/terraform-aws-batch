# terraform-aws-batch

Este módulo de Terraform permite crear y configurar entornos de AWS Batch con Fargate para la ejecución de trabajos en contenedores, incluyendo la salida del security group creado para el entorno.

## Uso básico

```hcl
module "batch" {
  source = "github.com/KaribuLab/terraform-aws-batch"
  
  name               = "mi-batch-job"
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  max_vcpus          = 4
  job_vcpu           = 1
  job_memory         = 2048
  job_command        = ["python", "script.py"]
  ecr_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/mi-repositorio"
  job_policy         = data.aws_iam_policy_document.mi_politica.json
  
  common_tags = {
    Environment = "production"
    Project     = "mi-proyecto"
  }
}
```

## Variables de entrada

| Nombre            | Descripción                                                  | Tipo           | Requerido |
|-------------------|--------------------------------------------------------------|----------------|-----------|
| name              | Nombre base para los recursos de AWS Batch                   | string         | Sí        |
| vpc_id            | ID de la VPC donde se desplegará el entorno de Batch         | string         | Sí        |
| subnet_ids        | Lista de IDs de subredes donde se ejecutarán los trabajos    | list(string)   | Sí        |
| max_vcpus         | Número máximo de vCPUs para el entorno de computación        | number         | Sí        |
| job_vcpu          | Número de vCPUs para cada trabajo                           | number         | Sí        |
| job_memory        | Memoria (en MiB) para cada trabajo                           | number         | Sí        |
| job_command       | Comando a ejecutar en el contenedor                          | list(string)   | Sí        |
| ecr_repository_url| URL del repositorio ECR con la imagen del contenedor         | string         | Sí        |
| job_policy        | Documento de política IAM para los trabajos                  | string         | Sí        |
| job_environment   | Variables de entorno para los trabajos                       | list(map(string)) | No     |
| job_timeout       | Tiempo máximo de ejecución de cada intento del job, en segundos (mínimo 60). Si se omite, el job no tiene timeout | number | No |
| common_tags       | Etiquetas a aplicar a todos los recursos                     | map(any)       | Sí        |

### Timeout del job

La variable `job_timeout` configura el bloque `timeout` de la definición de trabajo de AWS Batch (`attempt_duration_seconds`). Cuando un intento del job supera ese tiempo, AWS Batch lo termina y lo marca como `FAILED` con el motivo `Job attempt duration exceeded timeout`.

Consideraciones:

- El valor mínimo aceptado por AWS Batch es 60 segundos. El módulo valida esto en `terraform plan`.
- El timeout aplica por intento, no al job completo. Si se configuran reintentos, cada intento tiene su propio límite.
- Por defecto es `null`, lo que mantiene el comportamiento anterior: el job puede ejecutarse sin límite de tiempo.
- El timeout puede sobreescribirse al enviar un job con `aws batch submit-job --timeout attemptDurationSeconds=...`.

```hcl
module "batch" {
  source = "github.com/KaribuLab/terraform-aws-batch"

  # ... resto de variables ...

  job_timeout = 3600 # 1 hora
}
```

## Salidas

| Nombre              | Descripción                                      |
|---------------------|--------------------------------------------------|
| job_definition_name | Nombre de la definición de trabajo creada        |
| job_queue_name      | Nombre de la cola de trabajos creada             |
| job_definition_arn  | ARN de la definición de trabajo creada           |
| job_queue_arn       | ARN de la cola de trabajos creada                |
| security_group_id   | ID del security group creado para AWS Batch      |

## Recursos creados

Este módulo crea los siguientes recursos:

- Entorno de computación AWS Batch con Fargate
- Cola de trabajos AWS Batch
- Definición de trabajo AWS Batch
- Roles y políticas IAM necesarios
- Grupo de seguridad para los trabajos

## Ejemplo de ejecución

```bash
terraform init
terraform plan
terraform apply
```

## Licencia

Este proyecto está licenciado bajo los términos de la licencia Apache 2.0. Consulta el archivo LICENSE para más detalles.
