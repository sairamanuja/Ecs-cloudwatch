# ==============================================================================
# RDS DATABASE
# ==============================================================================
resource "aws_db_subnet_group" "strapi" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.a.id, aws_subnet.b.id]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "strapi" {
  # Database Configuration
  allocated_storage     = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.10"
  instance_class       = "db.t3.micro"
  
  # Database Settings
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  # Network & Security
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi.name
  publicly_accessible    = false
  
  # Backup & Maintenance
  skip_final_snapshot = true
  
  tags = {
    Name        = "${var.project_name}-database"
  }
}
