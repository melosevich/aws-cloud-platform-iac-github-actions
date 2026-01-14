terraform {
  backend "remote" {
    organization = "melosevich"

    workspaces {
      name = "dev-base"
    }
  }
}