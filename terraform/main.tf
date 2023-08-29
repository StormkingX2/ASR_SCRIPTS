#terraform to create a new portainer instance


terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

resource "docker_image" "portainer" {
  name         = "portainer/portainer-ce"
  keep_locally = true
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"

}

resource "docker_container" "portainer" {
  image = docker_image.portainer.image_id
  name  = "portainer"

  ports {
    internal = 8000
    external = 8000
   }

   ports {
     internal = 9443
     external = 9443
   }
  restart = "always"

  volumes{
    host_path      = docker_volume.portainer_data.mountpoint
    container_path = "/data"
  }

  volumes{
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}