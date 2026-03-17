#Specifying IAM resources
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#Setup frontend role and instance profile
resource "aws_iam_role" "fe" {
  name               = "${var.project}-${var.env}-frontend"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "IAM role for EC2 FE instance"
}

resource "aws_iam_role_policy_attachment" "fe" {

  for_each = var.instance_profile_policies

  role       = aws_iam_role.fe.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "fe" {
  name = "ec2-frontend-profile"
  role = aws_iam_role.fe.name

  depends_on = [aws_iam_role.fe]
}
