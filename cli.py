#!/usr/bin/env python3
"""
Brandy CLI - Command-line interface for INDECOPI Brand Name Generator
"""

import click
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich import box

from brandy import (
    BrandNameGenerator,
    SimilarityAnalyzer,
    ProbabilityCalculator,
    IndecopiScraper
)


console = Console()


@click.group()
@click.version_option(version='0.1.0')
def cli():
    """
    Brandy - INDECOPI Brand Name Generator

    Generate distinctive brand names that comply with Peruvian trademark guidelines.
    """
    pass


@cli.command()
@click.option('--count', '-c', default=10, help='Number of names to generate')
@click.option('--min-length', default=5, help='Minimum name length')
@click.option('--max-length', default=10, help='Maximum name length')
@click.option('--category', default='general', help='Business category')
@click.option('--style',
              type=click.Choice(['evocative', 'syllabic', 'modern', 'hybrid']),
              default='hybrid',
              help='Name generation style')
@click.option('--check/--no-check', default=False, help='Check against INDECOPI registry')
def generate(count, min_length, max_length, category, style, check):
    """
    Generate brand names.

    Examples:

        brandy generate --count 20 --style evocative

        brandy generate --count 10 --category technology --check
    """
    console.print("\n[bold cyan]🎨 Brandy - Brand Name Generator[/bold cyan]\n")

    # Initialize generator
    generator = BrandNameGenerator()

    # Generate names
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        task = progress.add_task(f"Generating {count} names...", total=None)

        names = generator.generate(
            count=count,
            min_length=min_length,
            max_length=max_length,
            category=category,
            style=style
        )

        progress.update(task, completed=True)

    # Display names
    table = Table(title="Generated Brand Names", box=box.ROUNDED)
    table.add_column("#", style="dim", width=4)
    table.add_column("Name", style="bold cyan")
    table.add_column("Length", justify="center")

    for i, name in enumerate(names, 1):
        table.add_row(str(i), name, str(len(name)))

    console.print(table)

    # Check against INDECOPI if requested
    if check:
        console.print("\n[yellow]Checking names against INDECOPI registry...[/yellow]")
        console.print("[dim]Note: This requires network access and may take time.[/dim]\n")

        scraper = IndecopiScraper()
        calculator = ProbabilityCalculator()

        # For demo purposes, check first 5 names
        check_count = min(5, len(names))

        for name in names[:check_count]:
            check_name_detailed(name, scraper, calculator)

    console.print(f"\n✨ Generated [bold]{len(names)}[/bold] distinctive brand names!\n")


@cli.command()
@click.argument('name')
@click.option('--category', type=int, help='NICE classification number')
@click.option('--detailed/--simple', default=False, help='Show detailed analysis')
def check(name, category, detailed):
    """
    Check a specific brand name against INDECOPI registry.

    Examples:

        brandy check "MiMarca"

        brandy check "TechNova" --category 9 --detailed
    """
    console.print(f"\n[bold cyan]🔍 Checking: {name}[/bold cyan]\n")

    scraper = IndecopiScraper()
    calculator = ProbabilityCalculator()

    if detailed:
        check_name_detailed(name, scraper, calculator, category)
    else:
        check_name_simple(name, scraper, calculator, category)


def check_name_simple(name, scraper, calculator, category=None):
    """Simple name check (quick overview)."""
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        task = progress.add_task("Searching INDECOPI registry...", total=None)

        # Search for similar marks
        existing_marks = scraper.search(name, search_type='phonetic', category=category)

        progress.update(task, description="Calculating probability...")

        # Calculate probability
        result = calculator.calculate(name, existing_marks, category)

        progress.update(task, completed=True)

    # Display result
    probability = result['probability']
    risk_level = result['risk_level']

    # Color based on risk
    if risk_level == "LOW":
        color = "green"
        emoji = "✅"
    elif risk_level == "MEDIUM":
        color = "yellow"
        emoji = "⚠️"
    else:
        color = "red"
        emoji = "❌"

    console.print(Panel(
        f"[bold]Name:[/bold] {name}\n"
        f"[bold]Registration Probability:[/bold] [{color}]{probability}%[/{color}]\n"
        f"[bold]Risk Level:[/bold] [{color}]{risk_level}[/{color}] {emoji}\n\n"
        f"{result['recommendation']}",
        title="Analysis Result",
        border_style=color
    ))


def check_name_detailed(name, scraper, calculator, category=None):
    """Detailed name check with full analysis."""
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        task = progress.add_task("Searching INDECOPI registry...", total=None)

        existing_marks = scraper.search(name, search_type='phonetic', category=category)

        progress.update(task, description="Analyzing similarity...")

        result = calculator.calculate(name, existing_marks, category)

        progress.update(task, completed=True)

    # Main result
    probability = result['probability']
    risk_level = result['risk_level']

    if risk_level == "LOW":
        color = "green"
    elif risk_level == "MEDIUM":
        color = "yellow"
    else:
        color = "red"

    console.print(Panel(
        f"[bold]Registration Probability:[/bold] [{color}]{probability}%[/{color}]\n"
        f"[bold]Risk Level:[/bold] [{color}]{risk_level}[/{color}]",
        title=f"📊 Analysis for: {name}",
        border_style=color
    ))

    # Detailed scores
    console.print("\n[bold]Detailed Scores:[/bold]")
    scores_table = Table(box=box.SIMPLE)
    scores_table.add_column("Factor", style="cyan")
    scores_table.add_column("Score", justify="right")
    scores_table.add_column("Weight", justify="right", style="dim")

    scores = result['scores']
    weights = {
        'distinctiveness': '40%',
        'phonetic_conflicts': '30%',
        'spelling_similarity': '20%',
        'category_overlap': '10%'
    }

    for factor, score in scores.items():
        factor_name = factor.replace('_', ' ').title()
        score_color = "green" if score >= 70 else "yellow" if score >= 50 else "red"
        scores_table.add_row(
            factor_name,
            f"[{score_color}]{score}[/{score_color}]",
            weights.get(factor, '')
        )

    console.print(scores_table)

    # Top conflicts
    if result['top_conflicts']:
        console.print("\n[bold]⚠️  Most Similar Existing Marks:[/bold]")
        conflicts_table = Table(box=box.ROUNDED)
        conflicts_table.add_column("Name", style="yellow")
        conflicts_table.add_column("Similarity", justify="center")
        conflicts_table.add_column("Holder", style="dim")
        conflicts_table.add_column("Class", justify="center")

        for conflict in result['top_conflicts']:
            sim_pct = f"{conflict['similarity'] * 100:.1f}%"
            sim_color = "red" if conflict['similarity'] >= 0.8 else "yellow"

            conflicts_table.add_row(
                conflict['name'],
                f"[{sim_color}]{sim_pct}[/{sim_color}]",
                conflict.get('holder', 'Unknown'),
                str(conflict.get('class', '-'))
            )

        console.print(conflicts_table)
    else:
        console.print("\n[green]✅ No significant conflicts found![/green]")

    # Recommendation
    console.print(f"\n[bold]Recommendation:[/bold]")
    console.print(Panel(result['recommendation'], border_style="blue"))


@cli.command()
@click.argument('name')
@click.option('--count', '-c', default=5, help='Number of variations to generate')
def variations(name, count):
    """
    Generate variations of a given name.

    Examples:

        brandy variations "Nova" --count 10
    """
    console.print(f"\n[bold cyan]🔄 Generating variations of: {name}[/bold cyan]\n")

    generator = BrandNameGenerator()
    vars = generator.generate_variations(name, count=count)

    table = Table(title=f"Variations of '{name}'", box=box.ROUNDED)
    table.add_column("#", style="dim", width=4)
    table.add_column("Variation", style="bold cyan")
    table.add_column("Length", justify="center")

    for i, var in enumerate(vars, 1):
        table.add_row(str(i), var, str(len(var)))

    console.print(table)
    console.print(f"\n✨ Generated [bold]{len(vars)}[/bold] variations!\n")


@cli.command()
@click.argument('name1')
@click.argument('name2')
def compare(name1, name2):
    """
    Compare two brand names for similarity.

    Examples:

        brandy compare "TechNova" "TekNova"
    """
    console.print(f"\n[bold cyan]⚖️  Comparing Names[/bold cyan]\n")

    analyzer = SimilarityAnalyzer()
    result = analyzer.analyze(name1, name2)

    # Main comparison
    overall = result['overall_score'] * 100
    color = "red" if overall >= 80 else "yellow" if overall >= 60 else "green"

    console.print(Panel(
        f"[bold]{name1}[/bold]  vs  [bold]{name2}[/bold]\n\n"
        f"[bold]Overall Similarity:[/bold] [{color}]{overall:.1f}%[/{color}]\n"
        f"[bold]Potential Conflict:[/bold] {'Yes ⚠️' if result['is_conflict'] else 'No ✅'}",
        title="Comparison Result",
        border_style=color
    ))

    # Detailed scores
    console.print("\n[bold]Similarity Breakdown:[/bold]")
    table = Table(box=box.SIMPLE)
    table.add_column("Metric", style="cyan")
    table.add_column("Score", justify="right")

    table.add_row("Phonetic", f"{result['phonetic_score'] * 100:.1f}%")
    table.add_row("Spelling", f"{result['spelling_score'] * 100:.1f}%")
    table.add_row("Visual", f"{result['visual_score'] * 100:.1f}%")

    console.print(table)

    # Algorithm details
    console.print("\n[bold dim]Algorithm Details:[/bold dim]")
    details_table = Table(box=box.SIMPLE, show_header=False)

    for algo, score in result['details'].items():
        if isinstance(score, float):
            details_table.add_row(algo.capitalize(), f"{score * 100:.1f}%")

    console.print(details_table)
    console.print()


@cli.command()
def clear_cache():
    """Clear the INDECOPI search cache."""
    scraper = IndecopiScraper()
    scraper.clear_cache()
    console.print("[green]✅ Cache cleared successfully![/green]")


if __name__ == '__main__':
    cli()
