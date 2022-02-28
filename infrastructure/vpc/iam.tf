# Create IAM roles for the ec2 instances

# IAM role that allows the auto-join to the consul datacenter
resource "aws_iam_role" "consul-join-role" {
  name               = "consul-join-role"
  assume_role_policy = file("${path.module}/policies/consul-join-role.json")
}

# Policy for the consul Auto-join role
resource "aws_iam_policy" "consul-join-policy" {
  name        = "consul-join-policy"
  description = "Allows Consul agents to describe instances for joining."
  policy      = file("${path.module}/policies/consul-join-policy.json")
}

# Attach policy to role - consul Auto-join
resource "aws_iam_policy_attachment" "attach-consul-join" {
  name       = "attach-consul-join"
  roles      = [aws_iam_role.consul-join-role.name]
  policy_arn = aws_iam_policy.consul-join-policy.arn
}

# Instance profile - for the consul Auto-join
resource "aws_iam_instance_profile" "consul-join-profile" {
  name      = "consul-join-profile"
  role      = aws_iam_role.consul-join-role.name
}

# IAM role for Jenkins Agents to access EKS cluster (this role will also allow them to join consul)
resource "aws_iam_role" "jenkins-access-eks-role" {
  name                = "jenkins-access-eks-role"
  assume_role_policy  = file("${path.module}/policies/jenkins-access-eks-role.json")
}

# Policy for the Jenkins Agents to access EKS cluster & join consul
resource "aws_iam_policy" "jenkins-access-eks-policy" {
  name        = "jenkins-access-eks-policy"
  description = "Allows Jenkins Agents to access EKS cluster."
  policy      = file("${path.module}/policies/jenkins-access-eks-policy.json")
}

# Attach policy to role - for the Jenkins Agents to access EKS cluster & join consul
resource "aws_iam_policy_attachment" "attach-jenkins-access-eks" {
  name       = "attach-jenkins-access-eks"
  roles      = [aws_iam_role.jenkins-access-eks-role.name]
  policy_arn = aws_iam_policy.jenkins-access-eks-policy.arn
}

# Instance profile - for Jenkins Agents to access EKS cluster & join consul
resource "aws_iam_instance_profile" "jenkins-access-eks-profile" {
  name      = "jenkins-access-eks-profile"
  role      = aws_iam_role.jenkins-access-eks-role.name
}