### ARCHITECTURE.md

```markdown
# Architecture of Agentic AI App

## System Design
 User Interface 
 (Flutter App)  
 FastAPI Server | | 
 (Python Backend)  
 Google Gemini (AI Model) 


Run
Copy code

## Components

### Planner
- The planner is responsible for generating business names, marketing strategies, and business plans based on user input.
- It utilizes the `BusinessNameGenerator`, `MarketingStrategyGenerator`, and `BusinessPlanGenerator` classes.

### Executor
- The executor handles the API requests to the Google Gemini model for content generation.
- It implements retry logic to ensure reliability in generating responses.

### Memory Structure
- The application uses a `MemoryManager` class to save and load session data, allowing users to retrieve their last session's details.

## Tool Integrations
- **Gemini API**: Used for generating business names, marketing strategies, and logos.
- **Search APIs**: (If applicable) for fetching additional data or insights.

## Logging and Observability
- The application uses Python's `logging` module to log important events, errors, and information for debugging and monitoring.
- Logs are saved to a file (`business_advisor.log`) and also output to the console.