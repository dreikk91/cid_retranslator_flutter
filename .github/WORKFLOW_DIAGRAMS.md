# CI/CD Workflow Diagram

## Build Process Flow

```mermaid
graph TB
    A[Push to GitHub] --> B{Trigger Type}
    B -->|Regular Push| C[build-windows.yml]
    B -->|Regular Push| D[build-linux.yml]
    B -->|Tag v*| E[build-release.yml]
    
    subgraph "Parallel Matrix Build"
        E --> F1[Windows Build]
        E --> F2[Linux Build]
    end
    
    F1 --> G1[Setup Env]
    F2 --> G2[Setup Env + Deps]
    
    G1 --> H1[Build Go .exe]
    G2 --> H2[Build Go binary]
    
    H1 --> I1[Build Flutter Win]
    H2 --> I2[Build Flutter Linux]
    
    I1 --> J1[Package ZIP]
    I2 --> J2[Package tar.gz]
    
    J1 --> K[Create Release]
    J2 --> K
    
    style A fill:#e1f5ff
    style E fill:#ffe1e1
    style K fill:#d4edda
```

## Package Contents

### Windows (.zip)
```mermaid
graph LR
    A[ZIP Package] --> B[cid_retranslator.exe]
    A --> C[cid_retranslator_backend.exe]
    A --> D[data/]
    A --> E[config.yaml]
    
    style A fill:#d4edda
    style B fill:#cfe2ff
```

### Linux (.tar.gz)
```mermaid
graph LR
    A[Tar.gz Package] --> B[cid_retranslator]
    A --> C[cid_retranslator_backend]
    A --> D[data/]
    A --> E[lib/]
    A --> F[config.yaml]
    
    style A fill:#fff3cd
    style B fill:#ffecb3
```

## Release Workflow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repository
    participant GH as GitHub Actions
    participant Rel as GitHub Releases
    
    Dev->>Git: git tag -a v1.0.0
    Dev->>Git: git push origin v1.0.0
    Git->>GH: Trigger workflow
    
    GH->>GH: Setup Go & Flutter
    GH->>GH: Build Go backend
    GH->>GH: Build Flutter app
    GH->>GH: Package everything
    GH->>GH: Create ZIP archive
    
    GH->>Rel: Upload ZIP to release
    GH->>Rel: Generate release notes
    
    Rel-->>Dev: Release v1.0.0 ready!
```

## Version Types

```mermaid
graph TD
    A[Git Action] --> B{Type?}
    
    B -->|Push to main| C[Development Build]
    B -->|Tag v1.2.3| D[Release v1.2.3]
    B -->|Manual Run| E[Manual Build]
    
    C --> F[dev-YYYYMMDD-HHMMSS]
    D --> G[v1.2.3]
    E --> H[dev-YYYYMMDD-HHMMSS]
    
    F --> I[Artifact Only]
    G --> J[Artifact + Release]
    H --> I
    
    style D fill:#d4edda
    style G fill:#d4edda
    style J fill:#d4edda
```

## Build Time Breakdown

| Stage | Estimated Time | Cached |
|-------|---------------|--------|
| Checkout | 10-20s | ❌ |
| Setup Go | 20-30s | ✅ |
| Setup Flutter | 60-90s | ✅ |
| Build Go Backend | 30-60s | Partial |
| Flutter pub get | 20-30s | ✅ |
| Flutter analyze | 10-20s | ❌ |
| Build Flutter App | 120-240s | Partial |
| Package & ZIP | 30-60s | ❌ |
| Upload | 20-40s | ❌ |
| **Total** | **5-10 min** | |

---

💡 **Tip:** Перший build займе більше часу, наступні будуть швидші завдяки кешуванню.
