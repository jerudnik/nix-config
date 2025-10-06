{ lib, ... }:

{
  imports = [
    # Functional organization of AI tools
    ./code-analysis      # Tools for converting code to prompts
    ./interfaces         # Direct LLM interaction tools  
    ./infrastructure     # Supporting systems and services
    ./utilities          # Management and diagnostics
  ];
}
