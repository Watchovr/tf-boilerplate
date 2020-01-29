resource "aws_appautoscaling_target" "target" {
    service_namespace = "ecs"
    resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    min_capacity = 1
    max_capacity = 2
}

resource "aws_appautoscaling_policy" "up" {
    name = "nx_scale_up"
    service_namespace = "ecs"
    resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
    scalable_dimension = "ecs:service:DesiredCount"

    step_scaling_policy_configuration {
        adjustment_type = "ChangeInCapacity"
        cooldown = 60
        metric_aggregation_type = "Maximum"

        step_adjustment {
            metric_interval_lower_bound = 0
            scaling_adjustment = 1
        }
    }

    depends_on = [aws_appautoscaling_target.target]
}

resource "aws_appautoscaling_policy" "down" {
    name = "nx_scale_down"
    service_namespace = "ecs"
    resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
    scalable_dimension = "ecs:service:DesiredCount"

    step_scaling_policy_configuration {
        adjustment_type = "ChangeInCapacity"
        cooldown = 60
        metric_aggregation_type = "Maximum"

        step_adjustment {
            metric_interval_lower_bound = 0
            scaling_adjustment = -1
        }
    }

    depends_on = [aws_appautoscaling_target.target]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
    alarm_name = "nx_cpu_utilization_high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "85"

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
    }

    alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
    alarm_name = "nx_cpu_utilization_low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/ECS"
    period = "60"
    statistic = "Average"
    threshold = "10"

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
    }

    alarm_actions = [aws_appautoscaling_policy.down.arn]
}
