resource "aws_cloudwatch_log_group" "nx_log_group" {
    name = "/ecs/nx-app"
    retention_in_days = 30

    tags = {
        Name = "nx-log-group"
    }
}

resource "aws_cloudwatch_log_stream" "nx_log_stream" {
    name = "nx-log-stream"
    log_group_name = aws_cloudwatch_log_group.nx_log_group.name
}
