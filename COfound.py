import os
import json
import random
import time
import logging
import sys
from datetime import datetime
from typing import List, Dict
from enum import Enum
from fastapi import FastAPI
from pydantic import BaseModel
from google import genai
from google.genai import types
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont
import ujson
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from memory import MemoryManager


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('business_advisor.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

# Configuration
LOGO_DIR = "generated_logos"
PLAN_DIR = "business_plans"
MODEL_NAME = "gemini-2.5-flash"

# Initialize Google AI client
client = genai.Client(api_key="AIzaSyC-kCENxlhAnZxU-q1x1Tvd9L8HW9B564Q")

# Enum for logo styles
class LogoStyle(str, Enum):
    MINIMAL = "minimal, simple, clean"
    CLASSIC = "classic, elegant, professional"
    MODERN = "modern, sleek, contemporary"
    FUN = "fun, colorful, playful"
    LUXURY = "luxury, premium, high-end"

# Data class for business details
class BusinessDetails(BaseModel):
    name: str
    area: str
    location: str
    region: str
    budget: float
    concept: str
    logo_style: LogoStyle
    
class BusinessSuggestion(BaseModel):
    area: str
    area: str
    location: str
    region: str
    budget: float
    concept: str
    logo_style: LogoStyle
    

# Initialize FastAPI app
app = FastAPI()
# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (you can specify your Flutter app's origin here)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, OPTIONS, etc.)
    allow_headers=["*"],  # Allow all headers
)
# Serve static files
app.mount("/generated_logos", StaticFiles(directory=LOGO_DIR), name="generated_logos")





@app.post("/suggest_names")
async def suggest_names(details: BusinessSuggestion):
    logging.info(f"Received details for name suggestion: {details}")
    
    try:
        name_generator = BusinessNameGenerator()
        suggestions = name_generator.suggest_names(details)  # Generate name suggestions
        
        return {"suggestions": suggestions}
    
    except Exception as e:
        logging.error(f"Error generating name suggestions: {str(e)}")
        return {"error": "An error occurred while generating name suggestions."}

@app.post("/process_business")
async def process_business(details: BusinessDetails):
    logging.info(f"Received details: {details}")
    
    try:
        # Generate logo
        logo_filename = generate_logo(details)  # This should return the filename
        logo_path = f"http://10.0.2.2:5000/generated_logos/{logo_filename}"
        logging.info(logo_path)
        
        # Generate marketing strategy as text
        marketing_generator = MarketingStrategyGenerator(details)
        marketing_plan = marketing_generator.generate_strategies()  # Call the method to generate strategies
        
        # Generate business plan as text
        business_plan_generator = BusinessPlanGenerator()
        business_plan = business_plan_generator.generate_plan(details)  # Call the method to generate the business plan
        
        # Prepare the response data
        result = {
            "business_name": details.name,
            "logo_path": logo_path,
            "marketing_plan": marketing_plan,  # This should be a string
            "business_plan": business_plan,  # This should be a string
            "area": details.area,
            "location": details.location,
            "region": details.region,
            "budget": details.budget,
            "concept": details.concept,
        }
        
               # Save the session data
        MemoryManager.save_session(result)
        
        logging.info(f"Processed result: {result}")
        return {"data": result}
    
    except Exception as e:
        logging.error(f"Error processing business details: {str(e)}")
        return {"error": "An error occurred while processing the request."}
    
@app.get("/load_last_session")
async def load_last_session():
    try:
        session_data = MemoryManager.load_last_session()
        if session_data:
            return session_data
        return {"error": "No session data found."}
    except Exception as e:
        logging.error(f"Error loading last session: {str(e)}")
        return {"error": "An error occurred while loading the session."}

        

def generate_with_retry(prompt: str, model: str = MODEL_NAME, max_retries: int = 3) -> str:
    """Generate content with retry logic"""
    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model=model,
                contents=[{"parts": [{"text": prompt}]}]
            )
            logging.info(f"Raw response from API: {response}")

           
            # Extract the text content from the response
            if response and hasattr(response, 'candidates') and len(response.candidates) > 0:
                candidate_text = response.candidates[0].content.parts[0].text
                
                # Clean the response
                candidate_text = candidate_text.replace('```json', '').replace('```', '').strip()

                # Check if the response is empty
                if not candidate_text:
                    logging.error("Received an empty response.")
                    raise ValueError("Empty response received.")

                # Check for unwanted text and extract JSON
                if candidate_text.startswith('json'):
                    candidate_text = candidate_text.split('\n', 1)[1].strip()  # Take the part after 'json'
                # Check if the response starts with a string and handle it
                
# Initialize json_start_index
                json_start_index = -1  # Set a default value
                if candidate_text.startswith('Okay,'):
                # Strip "Okay," from the beginning
                    candidate_text = candidate_text[len('Okay,'):].strip()
                elif candidate_text.startswith("Here's"):
    # Strip "Here's" from the beginning
                    candidate_text = candidate_text[len("here's"):].strip()
                    json_start_index = candidate_text.find('{')  # This line initializes json_start_index
                if json_start_index != -1:
                    candidate_text = candidate_text[json_start_index:]
# Attempt to parse the JSON
                

                # Attempt to parse the JSON
                try:
                    
                    if candidate_text.startswith('[') and candidate_text.endswith(']'):
                        return candidate_text  # Parse the JSON directly with ujson
                    # **Ensure the response is valid JSON**
                    if candidate_text.startswith('{') and candidate_text.endswith('}'):  # **New Check**
                        return candidate_text  # Parse the JSON directly with ujson
                    else:
                    # If it's not JSON, return the plain text
                        logging.warning(f"Received plain text instead of JSON: {candidate_text}")
                        return candidate_text  # Return the plain text response
                    
                    
#  else:
#      logging.error(f"Invalid JSON format: {candidate_text}")
#      raise ValueError("Invalid JSON format.")
                except ujson.JSONDecodeError as json_error:
                    logging.error(f"JSON decoding error: {json_error}. Response: {candidate_text}")
                    raise  # Re-raise the error for further handling

            time.sleep(1)  # Short delay between attempts
        except Exception as e:
            logging.warning(f"Attempt {attempt+1} failed: {str(e)}")
            if attempt == max_retries - 1:
                logging.error("Max retries reached. Unable to generate content.")
                raise
            # Exponential backoff
            time.sleep(2 ** attempt)
    return ""
def generate_logo(details: BusinessDetails) -> str:
    """Generate business logo with Gemini model"""
    try:
        prompt = f"""Create a professional logo for {details.name} ({details.area}) in {details.region}. 
                  Style: {details.logo_style}. Concept: {details.concept}
                  Requirements: Clean, vector-style, transparent background, no text."""
        
        logging.info("Generating logo with Gemini model...")
        
        response = client.models.generate_content(
            model="gemini-2.0-flash-preview-image-generation",
            contents=[{"parts": [{"text": prompt}]}],  # Ensure contents is structured correctly
            config=types.GenerateContentConfig(
                response_modalities=['TEXT', 'IMAGE']
            )
        )
        
        logging.info(f"Raw response from logo generation API: {response}")
        
        if not response.candidates:
            logging.error("No candidates found in the response.")
            return None
        
        for part in response.candidates[0].content.parts:
            if part.inline_data is not None:
                image = Image.open(BytesIO(part.inline_data.data))
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{details.name.replace(' ', '_')}_{timestamp}.png"
                
 # Save the image
                image.save(os.path.join(LOGO_DIR, filename))  # Save to the correct directory
                logging.info(f"Logo saved to {filename}")
                return filename  # Return only the filename
    except Exception as e:
        logging.error(f"Logo error: {str(e)}, using fallback")
        return generate_fallback_logo(details.name)
    

def generate_fallback_logo(name: str) -> str:
    """Create simple text logo if API fails"""
    img = Image.new('RGB', (512, 512), color=(73, 109, 137))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("arial.ttf", 40)
    except:
        font = ImageFont.load_default()
    d.text((100, 200), name, fill=(255, 255, 255), font=font)
    
    filename = f"{LOGO_DIR}/{name.replace(' ', '_')}_fallback.png"
    os.makedirs(LOGO_DIR, exist_ok=True)  # Ensure the directory exists
    img.save(filename)
    return filename

# Additional classes for generating business names, marketing strategies, and business plans...

# Ensure to include the rest of your classes and methods as needed

class BusinessNameGenerator:

    def suggest_names(self, details: BusinessSuggestion, count: int = 3) -> List[str]:
        """Generate business name suggestions with fallback"""
        try:
            prompt = f"""Suggest {count} creative names for a {details.area} business in {details.region}.
                      Concept: {details.concept}
                      Return ONLY JSON array of names, no explanations"""
                      
            response = generate_with_retry(prompt)
            
            # Check if the response is a list
            if isinstance(response, list):
                return response  # Directly return the list
            
            # If response is a string, parse it
            return ujson.loads(response)  # Use ujson to load the response
        except Exception as e:
            logging.error(f"Name generation failed: {str(e)}")
            return self._generate_fallback_names(details)

    def _generate_fallback_names(self, details: BusinessDetails) -> List[str]:
        """Local name generation fallback""" 
        prefixes = ["Elite", "Global", "Urban"]
        suffixes = ["Group", "Innovations", "Solutions"]
        return [
            f"{details.area.split()[0].capitalize()} {random.choice(suffixes)}",
            f"{details.location} {details.area.split()[0]}",
            f"{random.choice(prefixes)} {details.area.split()[0]}"
        ]

class MarketingStrategyGenerator:
    def __init__(self, details: BusinessDetails):
        self.details = details 

    def generate_strategies(self) -> str:
        """Generate marketing strategy as a text string"""
        try:
            prompt = f"""Create a marketing strategy for {self.details.name} ({self.details.area}) in {self.details.region}
                      Budget: ${self.details.budget:,.2f}
                      Concept: {self.details.concept}
                      Output in plain text format with: target_audience, digital_strategies (with costs), 
                      offline_strategies, budget_allocation, roi_metrics"""
            
            # Generate the strategy using the API
            strategy_text = generate_with_retry(prompt)
            return strategy_text  # Return the plain text
        except Exception as e:
            logging.error(f"Marketing strategy generation failed: {str(e)}")
            return self._generate_fallback_strategies()

    def _generate_fallback_strategies(self) -> str:
        """Local strategy generation fallback"""
        return """Target Audience: Local residents and businesses in the area
Digital Strategies:
- Social media ($300)
- Google Ads ($200)
Offline Strategies:
- Local events ($150)
- Flyers ($100)
Budget Allocation: Digital: $500, Offline: $300, Misc: $200
"""



class BusinessPlanGenerator:
    def generate_plan(self, details: BusinessDetails) -> str:
        """Generate business plan as a text string"""
        try:
            prompt = f"""Create a business plan for {details.name} ({details.area}) in {details.region}
                      Budget: ${details.budget:,.2f}
                      Concept: {details.concept}
                      Include: Executive Summary, Market Analysis, Marketing Strategy, 
                      Financial Projections in plain text format"""
            
            # Generate the plan using the API
            plan_text = generate_with_retry(prompt)
            return plan_text  # Return the plain text
        except Exception as e:
            logging.error(f"Business plan generation failed: {str(e)}")
            return self._generate_fallback_plan(details)

    def _generate_fallback_plan(self, details: BusinessDetails) -> str:
        """Local business plan fallback"""
        return f"""# Business Plan for {details.name}
            ## Concept
            {details.concept}

## Budget
            ${details.budget:,.2f} starting capital
"""


class BusinessAdvisor:
    def __init__(self):
        self.name_gen = BusinessNameGenerator()
        self.marketing_gen = MarketingStrategyGenerator()
        self.plan_gen = BusinessPlanGenerator()
    
    def create_business_assets(self, details: BusinessDetails) -> Dict:
        """Generate all business assets"""
        # If no name provided, generate suggestions
        if not details.name:
            names = self.name_gen.suggest_names(details)
            details.name = names[0]  # Use the first suggestion
        # Generate logo
        logo_path = generate_logo(details)
        # Generate marketing strategy
        marketing = self.marketing_gen.generate_strategies(details)
        marketing_file = f"{PLAN_DIR}/marketing_{details.name.replace(' ', '_')}.json"
        
        with open(marketing_file, "w") as f:
            json.dump(marketing, f, indent=2)
            
            # Generate business plan
        business_plan = self.plan_gen.generate_plan(details)
        plan_file = f"{PLAN_DIR}/plan_{details.name.replace(' ', '_')}.md"  # Define plan_file here
    
        with open(plan_file, "w") as f:
            f.write(business_plan)

        return {
        "business_name": details.name,
        "logo_path": logo_path,
        "marketing_plan_path": marketing_file,
        "business_plan_path": plan_file  # Include the business plan path
        }
