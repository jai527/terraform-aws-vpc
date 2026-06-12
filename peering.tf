resource "aws_vpc_peering_connection" "peer" {
count = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = data.aws_vpc.default.id

  auto_accept = true   # same account

  tags = {
    Name = "${var.project}-${var.environment}-to-default"
  }
}