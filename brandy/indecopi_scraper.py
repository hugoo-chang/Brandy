"""
INDECOPI Registry Scraper Module

Interfaces with INDECOPI trademark database to check existing marks.
Implements caching to reduce load on INDECOPI servers.
"""

import json
import pickle
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

from .config import (
    INDECOPI_SEARCH_URL,
    CACHE_DIR,
    CACHE_EXPIRY_DAYS,
    ENABLE_CACHE,
    SELENIUM_TIMEOUT,
    HEADLESS_BROWSER
)


class IndecopiScraper:
    """
    Scrapes INDECOPI trademark database for existing marks.
    """

    def __init__(self, use_cache: bool = ENABLE_CACHE):
        self.search_url = INDECOPI_SEARCH_URL
        self.cache_dir = CACHE_DIR
        self.use_cache = use_cache
        self.cache_expiry = timedelta(days=CACHE_EXPIRY_DAYS)

        # Create cache directory
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def search(
        self,
        query: str,
        search_type: str = 'phonetic',
        category: Optional[int] = None
    ) -> List[Dict]:
        """
        Search INDECOPI database for trademarks.

        Args:
            query: Search term (brand name)
            search_type: 'phonetic', 'exact', or 'partial'
            category: NICE classification number (optional)

        Returns:
            List of matching trademark records
        """
        # Check cache first
        if self.use_cache:
            cached_results = self._get_cached_results(query, search_type, category)
            if cached_results is not None:
                return cached_results

        # Perform actual search
        results = self._perform_search(query, search_type, category)

        # Cache results
        if self.use_cache:
            self._cache_results(query, search_type, category, results)

        return results

    def _perform_search(
        self,
        query: str,
        search_type: str,
        category: Optional[int]
    ) -> List[Dict]:
        """
        Perform actual search on INDECOPI website.

        Note: This is a placeholder implementation. The actual implementation
        would need to be adapted based on INDECOPI's actual website structure.
        """
        print(f"Searching INDECOPI for: {query} (type: {search_type})")

        try:
            # Option 1: Try requests first (faster if API exists)
            results = self._search_with_requests(query, search_type, category)
            if results:
                return results
        except Exception as e:
            print(f"Requests method failed: {e}")

        try:
            # Option 2: Fall back to Selenium for dynamic content
            results = self._search_with_selenium(query, search_type, category)
            return results
        except Exception as e:
            print(f"Selenium method failed: {e}")
            return []

    def _search_with_requests(
        self,
        query: str,
        search_type: str,
        category: Optional[int]
    ) -> List[Dict]:
        """
        Attempt search using requests library (if INDECOPI has simple forms).
        """
        # This is a placeholder - actual implementation depends on INDECOPI's site
        # The actual website might use AJAX/API calls that we can intercept

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        # Example POST to search endpoint (adjust based on actual site)
        search_payload = {
            'denominacion': query,
            'tipo_busqueda': search_type,
            'clase': category if category else ''
        }

        try:
            response = requests.post(
                self.search_url,
                data=search_payload,
                headers=headers,
                timeout=10
            )

            if response.status_code == 200:
                return self._parse_response(response.text)
        except Exception as e:
            print(f"Request error: {e}")

        return []

    def _search_with_selenium(
        self,
        query: str,
        search_type: str,
        category: Optional[int]
    ) -> List[Dict]:
        """
        Search using Selenium for JavaScript-rendered content.
        """
        driver = None
        try:
            # Setup Chrome options
            chrome_options = Options()
            if HEADLESS_BROWSER:
                chrome_options.add_argument('--headless')
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')

            # Initialize driver
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            driver.get(self.search_url)

            # Wait for page to load
            wait = WebDriverWait(driver, SELENIUM_TIMEOUT)

            # Find and fill search form
            # Note: These selectors need to be updated based on actual INDECOPI site
            try:
                search_input = wait.until(
                    EC.presence_of_element_located((By.ID, "denominacion"))
                )
                search_input.send_keys(query)

                # Select search type if available
                if search_type == 'phonetic':
                    # Find phonetic search radio/checkbox
                    phonetic_option = driver.find_element(By.ID, "busqueda_fonetica")
                    phonetic_option.click()

                # Submit search
                submit_button = driver.find_element(By.ID, "btnBuscar")
                submit_button.click()

                # Wait for results
                time.sleep(2)  # Give time for results to load

                # Parse results
                results = self._parse_selenium_results(driver)
                return results

            except Exception as e:
                print(f"Error during Selenium search: {e}")
                return []

        finally:
            if driver:
                driver.quit()

    def _parse_response(self, html: str) -> List[Dict]:
        """
        Parse HTML response to extract trademark data.
        """
        soup = BeautifulSoup(html, 'html.parser')
        results = []

        # This parsing logic needs to be adapted to actual INDECOPI HTML structure
        # Example structure:
        result_rows = soup.find_all('tr', class_='result-row')

        for row in result_rows:
            try:
                trademark = {
                    'denomination': row.find('td', class_='denomination').text.strip(),
                    'holder': row.find('td', class_='holder').text.strip(),
                    'class': row.find('td', class_='class').text.strip(),
                    'status': row.find('td', class_='status').text.strip(),
                    'registration_date': row.find('td', class_='date').text.strip(),
                }
                results.append(trademark)
            except Exception as e:
                # Skip malformed rows
                continue

        return results

    def _parse_selenium_results(self, driver) -> List[Dict]:
        """
        Parse results from Selenium WebDriver.
        """
        results = []

        try:
            # Wait for results table
            table = WebDriverWait(driver, SELENIUM_TIMEOUT).until(
                EC.presence_of_element_located((By.ID, "results-table"))
            )

            # Get all result rows
            rows = table.find_elements(By.TAG_NAME, "tr")[1:]  # Skip header

            for row in rows:
                try:
                    cells = row.find_elements(By.TAG_NAME, "td")
                    if len(cells) >= 4:
                        trademark = {
                            'denomination': cells[0].text.strip(),
                            'holder': cells[1].text.strip(),
                            'class': cells[2].text.strip(),
                            'status': cells[3].text.strip(),
                        }
                        results.append(trademark)
                except Exception:
                    continue

        except Exception as e:
            print(f"Error parsing Selenium results: {e}")

        return results

    def _get_cache_key(
        self,
        query: str,
        search_type: str,
        category: Optional[int]
    ) -> str:
        """Generate cache key for search query."""
        key_parts = [query.lower(), search_type]
        if category:
            key_parts.append(str(category))
        return "_".join(key_parts).replace(" ", "_")

    def _get_cached_results(
        self,
        query: str,
        search_type: str,
        category: Optional[int]
    ) -> Optional[List[Dict]]:
        """Retrieve cached results if available and not expired."""
        cache_key = self._get_cache_key(query, search_type, category)
        cache_file = self.cache_dir / f"{cache_key}.pickle"

        if not cache_file.exists():
            return None

        try:
            with open(cache_file, 'rb') as f:
                cached_data = pickle.load(f)

            # Check if cache is expired
            cached_time = datetime.fromisoformat(cached_data['timestamp'])
            if datetime.now() - cached_time > self.cache_expiry:
                return None

            print(f"Using cached results for: {query}")
            return cached_data['results']

        except Exception as e:
            print(f"Error reading cache: {e}")
            return None

    def _cache_results(
        self,
        query: str,
        search_type: str,
        category: Optional[int],
        results: List[Dict]
    ) -> None:
        """Cache search results."""
        cache_key = self._get_cache_key(query, search_type, category)
        cache_file = self.cache_dir / f"{cache_key}.pickle"

        cached_data = {
            'timestamp': datetime.now().isoformat(),
            'query': query,
            'search_type': search_type,
            'category': category,
            'results': results
        }

        try:
            with open(cache_file, 'wb') as f:
                pickle.dump(cached_data, f)
        except Exception as e:
            print(f"Error caching results: {e}")

    def get_all_trademarks(
        self,
        category: Optional[int] = None,
        limit: int = 1000
    ) -> List[Dict]:
        """
        Get a comprehensive list of trademarks (for building local database).

        Note: This should be used sparingly to avoid overloading INDECOPI servers.
        Consider requesting bulk data access from INDECOPI instead.
        """
        print("Warning: Bulk scraping should be done responsibly.")
        print("Consider contacting INDECOPI for official data access.")

        # This is a placeholder for bulk data retrieval
        # In practice, you should request official data access
        return []

    def clear_cache(self) -> None:
        """Clear all cached results."""
        for cache_file in self.cache_dir.glob("*.pickle"):
            cache_file.unlink()
        print("Cache cleared.")
