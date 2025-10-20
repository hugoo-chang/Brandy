#!/usr/bin/env python3
"""
Brandy API - REST API for Brand Name Generator

Optional FastAPI server for programmatic access.
"""

from typing import List, Optional
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from brandy import (
    BrandNameGenerator,
    SimilarityAnalyzer,
    ProbabilityCalculator,
    IndecopiScraper
)
from brandy.config import API_HOST, API_PORT


# Pydantic models for request/response
class GenerateRequest(BaseModel):
    count: int = Field(default=10, ge=1, le=100, description="Number of names to generate")
    min_length: int = Field(default=5, ge=3, le=20)
    max_length: int = Field(default=10, ge=3, le=20)
    category: str = Field(default="general")
    style: str = Field(default="hybrid", pattern="^(evocative|syllabic|modern|hybrid)$")


class GenerateResponse(BaseModel):
    names: List[str]
    count: int
    parameters: dict


class CheckRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=50)
    category: Optional[int] = Field(default=None, ge=1, le=45)


class CheckResponse(BaseModel):
    name: str
    probability: float
    risk_level: str
    scores: dict
    top_conflicts: List[dict]
    recommendation: str


class CompareRequest(BaseModel):
    name1: str = Field(..., min_length=2, max_length=50)
    name2: str = Field(..., min_length=2, max_length=50)


class CompareResponse(BaseModel):
    name1: str
    name2: str
    phonetic_score: float
    spelling_score: float
    visual_score: float
    overall_score: float
    is_conflict: bool
    details: dict


# Initialize FastAPI app
app = FastAPI(
    title="Brandy API",
    description="INDECOPI-compliant Brand Name Generator API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize components
generator = BrandNameGenerator()
analyzer = SimilarityAnalyzer()
calculator = ProbabilityCalculator()
scraper = IndecopiScraper()


@app.get("/")
async def root():
    """API root endpoint."""
    return {
        "name": "Brandy API",
        "version": "0.1.0",
        "description": "INDECOPI-compliant Brand Name Generator",
        "endpoints": {
            "generate": "/generate",
            "check": "/check",
            "compare": "/compare",
            "variations": "/variations/{name}",
            "docs": "/docs"
        }
    }


@app.post("/generate", response_model=GenerateResponse)
async def generate_names(request: GenerateRequest):
    """
    Generate brand names.

    Returns a list of distinctive brand names based on specified parameters.
    """
    try:
        names = generator.generate(
            count=request.count,
            min_length=request.min_length,
            max_length=request.max_length,
            category=request.category,
            style=request.style
        )

        return GenerateResponse(
            names=names,
            count=len(names),
            parameters=request.dict()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/check", response_model=CheckResponse)
async def check_name(request: CheckRequest):
    """
    Check a brand name against INDECOPI registry.

    Analyzes the name and returns registration probability with detailed breakdown.
    """
    try:
        # Search INDECOPI registry
        existing_marks = scraper.search(
            request.name,
            search_type='phonetic',
            category=request.category
        )

        # Calculate probability
        result = calculator.calculate(
            request.name,
            existing_marks,
            request.category
        )

        return CheckResponse(**result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/compare", response_model=CompareResponse)
async def compare_names(request: CompareRequest):
    """
    Compare two brand names for similarity.

    Returns detailed similarity analysis including phonetic, spelling, and visual scores.
    """
    try:
        result = analyzer.analyze(request.name1, request.name2)

        return CompareResponse(
            name1=request.name1,
            name2=request.name2,
            **result
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/variations/{name}")
async def generate_variations(
    name: str,
    count: int = Query(default=5, ge=1, le=20)
):
    """
    Generate variations of a given name.

    Returns alternative versions of the provided brand name.
    """
    try:
        variations = generator.generate_variations(name, count=count)

        return {
            "original": name,
            "variations": variations,
            "count": len(variations)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.delete("/cache")
async def clear_cache():
    """Clear the INDECOPI search cache."""
    try:
        scraper.clear_cache()
        return {"message": "Cache cleared successfully"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "brandy-api",
        "version": "0.1.0"
    }


if __name__ == "__main__":
    import uvicorn

    print("Starting Brandy API server...")
    print(f"API Documentation: http://{API_HOST}:{API_PORT}/docs")

    uvicorn.run(
        app,
        host=API_HOST,
        port=API_PORT,
        log_level="info"
    )
