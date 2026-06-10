locals {
    common_tags = {
    project = var.project
    environment = var.environment
    terraform = true
  }
  vpc_final_tags = merge(
    local.common_tags,
    {
        name = "${var.project}-${var.environment}"
    },
        var.vpc_tags
  )
    igw_final_tags = merge(
        local.common_tags,
        {
        name = "${var.project}-${var.environment}"
    },
    var.igw_tags
    )
    
}
