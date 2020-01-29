resource "aws_security_group" "lb" {
    name = "nx-load-balancer-security-group"
    description = "Controls ALB access"
    vpc_id = aws_vpc.main.id

    ingress {
        protocol = "tcp"
        from_port = var.app_port
        to_port = var.app_port
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_tasks" {
    name = "nx-ecs-tasks-security-group"
    description = "Controls inbound access to ECS from ALB"
    vpc_id = aws_vpc.main.id

    ingress {
        protocol = "tcp"
        from_port = var.app_port
        to_port = var.app_port
        security_groups = [aws_security_group.lb.id]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
