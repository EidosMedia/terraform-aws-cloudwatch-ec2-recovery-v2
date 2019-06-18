data "aws_region" "current" {}

locals {
  mincount = "${length(var.ec2_instances["names"]) < length(var.ec2_instances["ids"]) ? length(var.ec2_instances["names"]) : length(var.ec2_instances["ids"])}"
}

resource "aws_cloudwatch_metric_alarm" "this" {
  count              = "${local.mincount > 0 ? local.mincount : 0}"
  alarm_name         = "${element(var.ec2_instances["names"], count.index)}-StatusCheckFailed_System"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "${var.period}"
  statistic           = "${var.statistic}"

  dimensions = {
    InstanceId = "${element(var.ec2_instances["ids"], count.index)}"
  }

  alarm_actions = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover","${var.sns_mail_topic}"]
  threshold         = "${var.threshold}"
  alarm_description = "${var.alarm_description}"
}