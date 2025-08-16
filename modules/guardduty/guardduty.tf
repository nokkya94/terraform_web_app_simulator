resource "aws_guardduty_detector" "main_gd_detector" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "gd_s3_logs_protection" {
  detector_id = aws_guardduty_detector.main_gd_detector.id
  auto_enable_organization_members = "ALL" # or "NEW" or "NONE" as needed
  datasources {
     s3_logs {
    auto_enable = true
    }
  }
}