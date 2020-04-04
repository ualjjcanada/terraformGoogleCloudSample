# Descargar json con credenciales de aquí:
# https://console.cloud.google.com/apis/credentials/serviceaccountkey
# Tras ello definir la variable de entorno apuntando a el json
# export GOOGLE_CLOUD_KEYFILE_JSON=path/file.json

variable "gcp_project" {
  # Configurar el nombre del proyecto en GCP
  default = "cnsa-2020"
}

provider "google" {
  project     = "${var.gcp_project}"
  region      = "us-central1"
}
