#!/usr/bin/env python3
"""
Custom Layouts API Server for Hammerspoon

This script provides a simple HTTP API for storing and retrieving custom
window layout configurations in MongoDB.
"""

import os
import json
import logging
from bson import json_util
from flask import Flask, request, jsonify
from pymongo import MongoClient
from waitress import serve

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger("custom_layouts_api")

# Initialize Flask app
app = Flask(__name__)

# MongoDB setup
mongo_uri = os.environ.get("MONGO_URI", "mongodb://localhost:27017")
client = MongoClient(mongo_uri)
db = client["hammerspoon"]
layouts_collection = db["layouts"]

@app.route("/api/layouts", methods=["GET"])
def get_layouts():
    """Retrieve all layouts from MongoDB"""
    try:
        layouts = list(layouts_collection.find({}))
        # Convert ObjectId to string
        for layout in layouts:
            layout["_id"] = str(layout["_id"])
        return jsonify(layouts)
    except Exception as e:
        logger.error(f"Error retrieving layouts: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/layouts", methods=["POST"])
def create_layout():
    """Create a new layout in MongoDB"""
    try:
        layout_data = request.json
        
        # Check if a layout with this name already exists
        existing = layouts_collection.find_one({"name": layout_data["name"]})
        if existing:
            # Update existing layout
            layouts_collection.update_one(
                {"name": layout_data["name"]},
                {"$set": {"functions": layout_data["functions"]}}
            )
            return jsonify({"message": f"Layout '{layout_data['name']}' updated"}), 200
        
        # Insert new layout
        result = layouts_collection.insert_one(layout_data)
        return jsonify({
            "message": f"Layout '{layout_data['name']}' created",
            "id": str(result.inserted_id)
        }), 201
    except Exception as e:
        logger.error(f"Error creating layout: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/layouts/<string:layout_name>", methods=["GET"])
def get_layout(layout_name):
    """Retrieve a specific layout by name"""
    try:
        layout = layouts_collection.find_one({"name": layout_name})
        if not layout:
            return jsonify({"error": f"Layout '{layout_name}' not found"}), 404
        layout["_id"] = str(layout["_id"])
        return jsonify(layout)
    except Exception as e:
        logger.error(f"Error retrieving layout '{layout_name}': {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/layouts/<string:layout_name>", methods=["DELETE"])
def delete_layout(layout_name):
    """Delete a layout by name"""
    try:
        result = layouts_collection.delete_one({"name": layout_name})
        if result.deleted_count == 0:
            return jsonify({"error": f"Layout '{layout_name}' not found"}), 404
        return jsonify({"message": f"Layout '{layout_name}' deleted"})
    except Exception as e:
        logger.error(f"Error deleting layout '{layout_name}': {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    try:
        # Check MongoDB connection
        client.admin.command("ping")
        return jsonify({"status": "healthy", "mongodb": "connected"})
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({"status": "unhealthy", "error": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 27080))
    logger.info(f"Starting Custom Layouts API on port {port}")
    serve(app, host="0.0.0.0", port=port) 
