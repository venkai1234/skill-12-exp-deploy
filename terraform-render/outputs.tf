output "api_gateway_url" {
  description = "Public URL for login and book CRUD requests."
  value       = render_web_service.gateway.url
}

output "auth_service_url" {
  description = "Public auth service URL; use for diagnostics only."
  value       = render_web_service.auth.url
}

output "book_service_url" {
  description = "Public book service URL; use for diagnostics only."
  value       = render_web_service.book1.url
}
