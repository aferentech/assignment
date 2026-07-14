terraform {
  backend "gcs" {
    prefix = "assignment"
    bucket = "home-assignment-tfstate"
  }
}
