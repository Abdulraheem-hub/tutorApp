---
applyTo: '**'
---
# GitHub Copilot Instructions for Flutter + Firebase Mobile App
*Senior Developer Guidelines & Best Practices*

---

## 📱 Project Overview

This mobile application follows **industry-standard practices** with a **feature-first architecture** using:
- **Flutter** (Latest stable version)
- **Firebase** (Complete backend solution)
- **MCP Servers** (Context7 for enhanced development context)

---

## 🏗️ Feature-First Architecture

---

## 🛠️ MCP Server Integration with Context7

### Setup Context7 MCP Server
```bash
# Install Context7 MCP Server
npm install -g context7-mcp-server

# Configure in your IDE
# Add to your VS Code settings.json:
{
  "mcp.servers": {
    "context7": {
      "command": "context7-mcp-server",
      "args": ["--project-path", ".", "--context-depth", "7"]
    }
  }
}
```

### Using Context7 for Better Copilot Context
```dart
// Example: Add context comments for Copilot
/**
 * @context7:feature:authentication
 * @context7:dependencies:firebase_auth,bloc,equatable
 * @context7:pattern:clean_architecture
 * 
 * Authentication feature implementation following clean architecture
 * with Firebase Auth integration and BLoC state management
 */
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Copilot will have full context of the authentication feature
}
```

---

## 🏆 Senior Developer Best Practices

## 📚 Development Workflow

### 1. Feature Development Process
1. **Create feature branch**: `feature/user-profile`
2. **Set up feature structure** following the architecture
3. **Implement domain layer** (entities, use cases, repositories)
4. **Implement data layer** (models, data sources, repository implementation)
5. **Implement presentation layer** (BLoC, pages, widgets)
6. **Write tests** for each layer

### 2. Code Review Checklist
- [ ] Follows feature-first architecture
- [ ] Proper error handling implemented
- [ ] Unit tests written and passing
- [ ] Performance optimizations considered
- [ ] Security best practices followed
- [ ] Documentation updated

---

follow  Security Best Practices



