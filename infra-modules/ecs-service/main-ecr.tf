resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire images as soon as newer one is pushed",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 1
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}

