Vous avez raison, certaines idées se chevauchent et ne sont pas toujours compatibles. Voici donc un scénario cohérent unique pour gérer efficacement plusieurs environnements (prod, staging, dev) avec Terraform.

Scénario : Utilisation des modules, des backends séparés, et des fichiers de variables par environnement

Dans ce scénario, nous allons structurer votre code Terraform de manière à avoir :

	1.	Une organisation des fichiers par environnement pour maintenir une séparation claire.
	2.	Un module centralisé et réutilisable pour éviter la duplication du code.
	3.	Des fichiers de variables spécifiques à chaque environnement (dev, staging, prod) pour gérer les configurations.
	4.	Des backends séparés pour isoler les états Terraform de chaque environnement et éviter les conflits.

Structure de répertoires

Nous allons organiser le projet avec les dossiers pour chaque environnement et un dossier pour les modules partagés.

.
├── environments
│   ├── dev
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── dev.tfvars
│   ├── staging
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── staging.tfvars
│   └── prod
│       ├── main.tf
│       ├── backend.tf
│       └── prod.tfvars
└── modules
    └── app_module
        ├── main.tf
        └── variables.tf

Étape 1 : Créer un module réutilisable

Le module se trouve dans le dossier modules/app_module. Ce module contient toute la logique pour déployer les ressources nécessaires (par exemple, une instance EC2, une base de données, etc.).

# modules/app_module/main.tf
resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "${var.environment}-app-instance"
  }
}

resource "aws_db_instance" "database" {
  identifier   = "${var.environment}-db"
  engine       = "mysql"
  instance_class = var.db_instance_class
  allocated_storage = 20
}

Et les variables :

# modules/app_module/variables.tf
variable "ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
}

Étape 2 : Configurer chaque environnement

Dans chaque environnement, nous allons :

	1.	Appeler le module.
	2.	Configurer un backend spécifique.
	3.	Utiliser des fichiers de variables pour les paramètres spécifiques à l’environnement.

Exemple pour dev

# environments/dev/main.tf
module "app" {
  source = "../../modules/app_module"
  ami = "ami-12345678"
  instance_type = "t2.micro"
  environment = "dev"
  db_instance_class = "db.t3.micro"
}

Le fichier dev.tfvars contiendra les valeurs spécifiques à l’environnement dev. Il peut remplacer les variables globales ou ajouter des informations additionnelles si nécessaire.

# environments/dev/dev.tfvars
ami = "ami-87654321"
instance_type = "t2.small"
db_instance_class = "db.t3.small"

Backend spécifique pour dev

# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-dev-state"
    key    = "terraform/dev/terraform.tfstate"
    region = "us-west-2"
  }
}

Étape 3 : Répéter pour les autres environnements

Pour staging et prod, la structure est la même, mais avec des variables, des backends et des configurations spécifiques à ces environnements.

Exemple pour prod

# environments/prod/main.tf
module "app" {
  source = "../../modules/app_module"
  ami = "ami-12345678"
  instance_type = "t2.large"
  environment = "prod"
  db_instance_class = "db.m5.large"
}

# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-prod-state"
    key    = "terraform/prod/terraform.tfstate"
    region = "us-east-1"
  }
}

# environments/prod/prod.tfvars
ami = "ami-09876543"
instance_type = "t2.xlarge"
db_instance_class = "db.m5.large"

Étape 4 : Exécuter Terraform par environnement

Pour exécuter Terraform dans chaque environnement, vous devez vous rendre dans le dossier correspondant et utiliser le fichier de variables approprié.

Exemple pour dev

cd environments/dev

# Initialiser avec le backend spécifique
terraform init

# Appliquer les configurations pour l'environnement dev
terraform apply -var-file="dev.tfvars"

Pour staging ou prod, il suffit de répéter l’opération dans les répertoires respectifs.

Avantages de ce scénario

	1.	Séparation claire : Chaque environnement a ses propres fichiers de backend, état, et configurations.
	2.	Réutilisation du code : Le module central évite la duplication du code pour la gestion des ressources.
	3.	Flexibilité : Les fichiers de variables permettent des ajustements précis pour chaque environnement.
	4.	Isolation des états : Chaque environnement a son propre backend d’état (par exemple un bucket S3 séparé), garantissant une isolation totale.

Conclusion

Avec cette approche :

	•	Les environnements sont bien séparés et indépendants, réduisant le risque d’erreurs entre dev, staging et prod.
	•	Le module Terraform centralisé permet de maintenir un code DRY (Don’t Repeat Yourself), facilitant les mises à jour.
	•	Les backends séparés garantissent la sécurité et l’isolation des états Terraform.

Cela vous offre une approche modulaire, scalable et maintenable pour gérer plusieurs environnements en parallèle avec Terraform.