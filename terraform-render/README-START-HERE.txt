SKILL-12-EXP: DEPLOYMENT ON RENDER USING DOCKER AND TERRAFORM
Project folder: skill-12-exp-Deployment-render-using-docker-Terraform
All commands below are for Windows Command Prompt (CMD), not PowerShell.

RESOURCE NAMES IN THIS VERSION
- skill-12-exp-library-db
- skill-12-exp-library-auth
- skill-12-exp-library-book-1
- skill-12-exp-library-gateway

ARCHITECTURE
- API Gateway, Auth Service, and Book Service are separate Render web services.
- Eureka Server is included for the local Docker Compose demonstration only; Terraform does not deploy it.
- The gateway routes /api/auth/** and /api/books/** to the public HTTPS URLs of the auth and book services.
- Render PostgreSQL stores book records.

IMPORTANT BEFORE DEPLOYING
Changing names in main.tf does not rename services already created in Render by itself. Terraform may propose creating new services, replacing resources, or destroying resources depending on the state file and configuration.
If you have an earlier skill-11 deployment or an existing terraform.tfstate, do NOT blindly apply this configuration. First inspect `terraform state list` and `terraform plan`. Do not apply if the plan proposes unexpected deletes/replacements. Keep a backup of any state file and export any database data you need.

FREE-TIER NOTES
- Free web services may sleep after inactivity and take time to wake.
- Free PostgreSQL plans have time/storage limits and may expire; verify current Render terms/dashboard before deploying.
- Free-tier availability and payment verification requirements are controlled by Render and can change.
- This is for learning/testing, not production. Protect public endpoints and secrets.

REPOSITORY SETUP
1. Push the complete project to a GitHub repository. Its root must contain compose.yaml, the service directories, and terraform-render/.
2. Open CMD and change to the terraform folder, for example:
   cd /d "%USERPROFILE%\Downloads\skill-12-exp-Deployment-render-using-docker-Terraform\skill-12-exp-Deployment-render-using-docker-Terraform\terraform-render"
   Adjust the path if your extracted folder is in a different location.
3. Set credentials in this CMD window only. Never paste or commit secrets:
   set "RENDER_API_KEY=YOUR_NEW_RENDER_API_KEY"
   set "RENDER_OWNER_ID=YOUR_RENDER_OWNER_ID"
   set "TF_VAR_jwt_secret=REPLACE_WITH_A_RANDOM_SECRET_AT_LEAST_32_CHARACTERS_LONG"
   Use a newly generated Render API key; revoke any key that has previously been exposed.
4. Initialize and validate:
   terraform init -upgrade
   terraform fmt
   terraform validate
   terraform state list
5. Create a plan, substituting your actual GitHub repository URL:
   terraform plan -var="repo_url=https://github.com/YOUR-USERNAME/YOUR-REPOSITORY" -out="render-free.tfplan"
   Do not add `.git` unless your Render provider/repository setup specifically accepts it; use the repository URL verified in Render.
6. Read the plan carefully. For a clean new state, the expected configuration includes one PostgreSQL database and three web services. Confirm all names begin `skill-12-exp-`. If you see unexpected replacements/deletions, stop and reconcile the existing state before continuing.
7. Only after confirming the plan is safe, run:
   terraform apply "render-free.tfplan"
8. Check service URLs:
   terraform output
   Copy api_gateway_url from the output, then run (replace with the actual URL):
   curl.exe -i https://YOUR-GATEWAY.onrender.com/actuator/health
   curl.exe -i -X POST https://YOUR-GATEWAY.onrender.com/api/auth/login -H "Content-Type: application/json" -d "{"username":"admin","password":"admin123"}"

API TESTING
After login, copy the returned token. Use the exact token in CMD (do not include the word Bearer in the variable):
   set "TOKEN=PASTE_TOKEN_HERE"
   set "GATEWAY=https://YOUR-GATEWAY.onrender.com"
   curl.exe -i -X GET "%GATEWAY%/api/books" -H "Authorization: Bearer %TOKEN%"
Create a book:
   curl.exe -i -X POST "%GATEWAY%/api/books" -H "Content-Type: application/json" -H "Authorization: Bearer %TOKEN%" -d "{"title":"Cloud Computing","author":"Dr. Venkateswarlu","isbn":"SKILL12-001"}"
Use the ID returned by POST for GET/PUT/DELETE. For PUT, send a complete JSON object with title, author, and isbn. DELETE normally returns HTTP 204 with no body.

LOCAL DOCKER COMPOSE
From the project root (the folder containing compose.yaml):
   docker compose up --build -d
   docker compose ps
   docker compose logs -f
Stop containers (keeps the database volume):
   docker compose down
To remove containers AND the local database volume, which deletes local database data:
   docker compose down -v

CLEANUP ON RENDER
Do not run destroy unless you intentionally want to delete all Terraform-managed resources and possibly database data. From terraform-render, first run:
   terraform plan -destroy -var="repo_url=https://github.com/YOUR-USERNAME/YOUR-REPOSITORY" -out="destroy.tfplan"
Review the plan, then only if correct run:
   terraform apply "destroy.tfplan"

TROUBLESHOOTING
- Free services can take time to wake up; check Render deploy/runtime logs.
- HTTP 401 on /api/books without a Bearer token is expected.
- If GitHub repository selection or deploy fails, verify the repository URL, branch, and Render GitHub connection.
- Never share Render API keys, JWT secrets, or live access tokens in screenshots or chat.
