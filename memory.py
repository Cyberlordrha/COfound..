import json
import os

class MemoryManager:
    MEMORY_FILE = 'last_session.json'

    @staticmethod
    def save_session(data):
        """Save the session data to a JSON file."""
        with open(MemoryManager.MEMORY_FILE, 'w') as f:
            json.dump(data, f)

    @staticmethod
    def load_last_session():
        """Load the last session data from a JSON file."""
        if os.path.exists(MemoryManager.MEMORY_FILE):
            with open(MemoryManager.MEMORY_FILE, 'r') as f:
                return json.load(f)
        return None
