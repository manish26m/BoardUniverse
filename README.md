# BoardUniverse 🎲

A full-stack board game catalogue web application built with Spring Boot, containerized with Docker, and deployed using a complete CI/CD pipeline.

## About This Project

BoardUniverse is a platform where users can browse, add, and review board games. The project includes a complete DevOps pipeline that automatically builds, tests, scans, and deploys the application whenever new code is pushed.

**Developer:** Manish Mishra  
**Project Type:** College DevOps CI/CD Project  

---

## Application Features

- Browse a catalogue of board games and their reviews
- User authentication and role-based access control
  - **Guest** – can view board games and reviews
  - **User** – can add new board games and post reviews
  - **Manager** – can edit and delete reviews
- Secured with Spring Security
- In-memory H2 database for fast development and testing
- Responsive UI with Bootstrap and Thymeleaf templates

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 11, Spring Boot 2.5.6 |
| Frontend | Thymeleaf, HTML5, CSS3, Bootstrap |
| Security | Spring Security |
| Database | H2 (in-memory) |
| Build Tool | Apache Maven |
| Testing | JUnit, JaCoCo |

---

## DevOps Pipeline

This project uses a fully automated CI/CD pipeline with the following tools:

| Tool | Purpose |
|---|---|
| Jenkins | Orchestrates the entire pipeline |
| Maven | Compiles, tests, and packages the app |
| SonarQube | Static code analysis and quality gate |
| Trivy | Security vulnerability scanning |
| Nexus | Artifact repository for storing JARs |
| Docker | Containerizes the application |
| DockerHub | Stores and distributes Docker images |
| GitHub Webhook | Triggers pipeline on every push |

### Pipeline Stages

```
Git Checkout → Compile → Test → Trivy FS Scan →
SonarQube Analysis → Quality Gate → Build JAR →
Publish to Nexus → Docker Build → Trivy Image Scan →
Docker Push → Deploy → Email Notification
```

---

## How to Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/manish26m/Boardgame.git
   cd Boardgame
   ```

2. Build and run with Maven:
   ```bash
   mvn spring-boot:run
   ```

3. Open your browser at: `http://localhost:8080`

4. Default test credentials:
   - Username: `bugs` | Password: `bunny` (User role)
   - Username: `daffy` | Password: `duck` (Manager role)

---

## Running with Docker

```bash
docker pull manish26m/boardgame:latest
docker run -d -p 8085:8080 --name boardgame manish26m/boardgame:latest
```

Open: `http://localhost:8085`

---

## CI/CD Setup Requirements

- Jenkins (with Pipeline, Docker, SonarQube, Nexus plugins)
- SonarQube server
- Nexus Repository Manager
- Docker Desktop
- Trivy
