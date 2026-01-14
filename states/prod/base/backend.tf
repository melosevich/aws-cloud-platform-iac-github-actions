terraform {
  backend "remote" {
    organization = "melosevich"

    workspaces {
      name = "prod-base"
    }
  }
}