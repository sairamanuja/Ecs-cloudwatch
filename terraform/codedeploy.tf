# ==============================================================================
# CODEDEPLOY APPLICATION
# ==============================================================================
resource "aws_codedeploy_app" "strapi" {
  name             = "${var.project_name}-deploy-app"
  compute_platform = "ECS"

  tags = {
    Name = "${var.project_name}-deploy-app"
  }
}

# ==============================================================================
# CODEDEPLOY DEPLOYMENT GROUP
# ==============================================================================
resource "aws_codedeploy_deployment_group" "strapi" {
  app_name               = aws_codedeploy_app.strapi.name
  deployment_group_name  = "${var.project_name}-deploy-group"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  # Tell CodeDeploy this is for ECS
  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.this.name
  }

  # Blue/Green deployment style
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configure Blue/Green settings
  blue_green_deployment_config {
    # How to handle old (Blue) instances after deployment
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    # How to route traffic during deployment
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  # Load balancer configuration for traffic shifting
  load_balancer_info {
    target_group_pair_info {
      # Production listener (port 80)
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      # Test listener (port 8080) - for testing before full traffic shift
      test_traffic_route {
        listener_arns = [aws_lb_listener.test.arn]
      }

      # Blue target group (current production)
      target_group {
        name = aws_lb_target_group.blue.name
      }

      # Green target group (new deployment)
      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  # Automatic rollback on deployment failure
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  tags = {
    Name = "${var.project_name}-deploy-group"
  }
}
