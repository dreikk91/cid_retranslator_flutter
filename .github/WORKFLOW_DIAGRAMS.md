# CI/CD Workflow Diagram

## Build Process Flow

```mermaid
graph TB
    A[Push to GitHub] --> B{Trigger Type}
    B -->|Regular Push| C[build-windows.yml]
    B -->|Tag v*| D[build-release.yml]
    
    C --> E1[Setup Go 1.23]
    C --> E2[Setup Flutter 3.27]
    
    D --> F1[Setup Go 1.23]
    D --> F2[Setup Flutter 3.27]
    
    E1 --> G1[Build Go Backend]
    E2 --> G2[Build Flutter App]
    
    F1 --> H1[Build Go Backend -ldflags]
    F2 --> H2[Flutter Analyze]
    H2 --> H3[Build Flutter App]
    
    G1 --> I1[Package Together]
    G2 --> I1
    
    H1 --> I2[Package + Versioning]
    H3 --> I2
    
    I1 --> J1[Upload Artifact]
    I2 --> J2[Upload Artifact]
    I2 --> K[Create GitHub Release]
    
    J1 --> L1[Available in Actions]
    J2 --> L2[Available in Actions]
    K --> L3[Available in Releases]
    
    style A fill:#e1f5ff
    style C fill:#fff4e1
    style D fill:#ffe1e1
    style K fill:#d4edda
    style L3 fill:#d4edda
```

## Package Contents

```mermaid
graph LR
    A[ZIP Package] --> B[cid_retranslator.exe]
    A --> C[cid_retranslator_backend.exe]
    A --> D[data/]
    A --> E[config.yaml]
    A --> F[icons]
    A --> G[README files]
    
    B -->|Flutter UI| B1[Windows Desktop App]
    C -->|Go Server| C1[WebSocket Backend]
    D -->|Resources| D1[Flutter Assets]
    
    style A fill:#d4edda
    style B fill:#cfe2ff
    style C fill:#cfe2ff
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
