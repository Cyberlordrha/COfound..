import json
import os

class MemoryManager:
    MEMORY_FILE = 'last_sessions.json'

    @staticmethod
    def save_session(data):
        """Save the session data to a JSON file."""
        sessions = MemoryManager.load_sessions()
        sessions.append(data)  # Append the new session
        with open(MemoryManager.MEMORY_FILE, 'w') as f:
            json.dump(sessions, f)

    @staticmethod
    def load_sessions():
        """Load all session data from a JSON file."""
        if os.path.exists(MemoryManager.MEMORY_FILE):
            with open(MemoryManager.MEMORY_FILE, 'r') as f:
                return json.load(f)
        return []
    
    @staticmethod
    def load_last_session():
        """Load the last session data from a JSON file."""
        sessions = MemoryManager.load_sessions()
        if sessions:
            return sessions[-1]  # Return the most recent session
        return None
