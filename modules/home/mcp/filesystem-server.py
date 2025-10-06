#!/usr/bin/env python3
"""
Simple filesystem MCP server implementation
Provides basic file operations for Claude Desktop
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, Any, List

class SimpleFilesystemMCPServer:
    def __init__(self, allowed_path: str = None):
        self.allowed_path = Path(allowed_path) if allowed_path else Path.home()
        
    def initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "jsonrpc": "2.0",
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {
                        "listChanged": False
                    },
                    "resources": {
                        "subscribe": False,
                        "listChanged": False  
                    }
                },
                "serverInfo": {
                    "name": "simple-filesystem-server",
                    "version": "1.0.0"
                }
            }
        }
    
    def list_tools(self) -> Dict[str, Any]:
        return {
            "jsonrpc": "2.0",
            "result": {
                "tools": [
                    {
                        "name": "read_file",
                        "description": f"Read the contents of a file within {self.allowed_path}",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "path": {
                                    "type": "string",
                                    "description": "Path to the file to read"
                                }
                            },
                            "required": ["path"]
                        }
                    },
                    {
                        "name": "list_directory",
                        "description": f"List contents of a directory within {self.allowed_path}",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "path": {
                                    "type": "string",
                                    "description": "Path to the directory to list",
                                    "default": str(self.allowed_path)
                                }
                            }
                        }
                    },
                    {
                        "name": "get_file_info",
                        "description": f"Get information about a file or directory within {self.allowed_path}",
                        "inputSchema": {
                            "type": "object", 
                            "properties": {
                                "path": {
                                    "type": "string",
                                    "description": "Path to get info for"
                                }
                            },
                            "required": ["path"]
                        }
                    }
                ]
            }
        }
    
    def is_path_allowed(self, path_str: str) -> bool:
        try:
            path = Path(path_str).resolve()
            return path.is_relative_to(self.allowed_path)
        except:
            return False
    
    def handle_tool_call(self, name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        try:
            if name == "read_file":
                return self.read_file(arguments["path"])
            elif name == "list_directory":
                return self.list_directory(arguments.get("path", str(self.allowed_path)))
            elif name == "get_file_info":
                return self.get_file_info(arguments["path"])
            else:
                return {
                    "jsonrpc": "2.0",
                    "error": {
                        "code": -32601,
                        "message": f"Unknown tool: {name}"
                    }
                }
        except Exception as e:
            return {
                "jsonrpc": "2.0", 
                "error": {
                    "code": -32000,
                    "message": f"Tool execution failed: {str(e)}"
                }
            }
    
    def read_file(self, path_str: str) -> Dict[str, Any]:
        if not self.is_path_allowed(path_str):
            raise Exception(f"Access denied: {path_str} is outside allowed path")
            
        path = Path(path_str)
        if not path.exists():
            raise Exception(f"File not found: {path_str}")
            
        if not path.is_file():
            raise Exception(f"Not a file: {path_str}")
            
        try:
            content = path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            # Try to read as binary and show first 1024 bytes
            content = f"[Binary file - first 1024 bytes as hex]\n{path.read_bytes()[:1024].hex()}"
            
        return {
            "jsonrpc": "2.0",
            "result": {
                "content": [
                    {
                        "type": "text",
                        "text": f"Contents of {path_str}:\n\n{content}"
                    }
                ]
            }
        }
    
    def list_directory(self, path_str: str) -> Dict[str, Any]:
        if not self.is_path_allowed(path_str):
            raise Exception(f"Access denied: {path_str} is outside allowed path")
            
        path = Path(path_str)
        if not path.exists():
            raise Exception(f"Directory not found: {path_str}")
            
        if not path.is_dir():
            raise Exception(f"Not a directory: {path_str}")
            
        items = []
        for item in sorted(path.iterdir()):
            items.append({
                "name": item.name,
                "type": "directory" if item.is_dir() else "file",
                "size": item.stat().st_size if item.is_file() else None,
                "path": str(item)
            })
            
        return {
            "jsonrpc": "2.0", 
            "result": {
                "content": [
                    {
                        "type": "text",
                        "text": f"Contents of {path_str}:\n\n" + "\n".join([
                            f"{'📁' if item['type'] == 'directory' else '📄'} {item['name']}"
                            + (f" ({item['size']} bytes)" if item['size'] is not None else "")
                            for item in items
                        ])
                    }
                ]
            }
        }
    
    def get_file_info(self, path_str: str) -> Dict[str, Any]:
        if not self.is_path_allowed(path_str):
            raise Exception(f"Access denied: {path_str} is outside allowed path")
            
        path = Path(path_str)
        if not path.exists():
            raise Exception(f"Path not found: {path_str}")
            
        stat = path.stat()
        info = {
            "path": str(path),
            "name": path.name,
            "type": "directory" if path.is_dir() else "file",
            "size": stat.st_size,
            "modified": stat.st_mtime,
            "permissions": oct(stat.st_mode)
        }
        
        return {
            "jsonrpc": "2.0",
            "result": {
                "content": [
                    {
                        "type": "text", 
                        "text": f"Information for {path_str}:\n\n" + "\n".join([
                            f"Name: {info['name']}",
                            f"Type: {info['type']}",
                            f"Size: {info['size']} bytes",
                            f"Modified: {info['modified']}",
                            f"Permissions: {info['permissions']}"
                        ])
                    }
                ]
            }
        }

def main():
    allowed_path = sys.argv[1] if len(sys.argv) > 1 else str(Path.home())
    server = SimpleFilesystemMCPServer(allowed_path)
    
    for line in sys.stdin:
        try:
            request = json.loads(line.strip())
            response = None
            
            if request.get("method") == "initialize":
                response = server.initialize(request.get("params", {}))
                response["id"] = request.get("id")
                
            elif request.get("method") == "tools/list":
                response = server.list_tools()
                response["id"] = request.get("id")
                
            elif request.get("method") == "tools/call":
                params = request.get("params", {})
                tool_name = params.get("name")
                arguments = params.get("arguments", {})
                response = server.handle_tool_call(tool_name, arguments)
                response["id"] = request.get("id")
                
            else:
                response = {
                    "jsonrpc": "2.0",
                    "id": request.get("id"),
                    "error": {
                        "code": -32601,
                        "message": f"Unknown method: {request.get('method')}"
                    }
                }
            
            if response:
                print(json.dumps(response), flush=True)
                
        except json.JSONDecodeError:
            error_response = {
                "jsonrpc": "2.0", 
                "error": {
                    "code": -32700,
                    "message": "Parse error"
                }
            }
            print(json.dumps(error_response), flush=True)
        except Exception as e:
            error_response = {
                "jsonrpc": "2.0",
                "id": request.get("id") if 'request' in locals() else None,
                "error": {
                    "code": -32000,
                    "message": f"Internal error: {str(e)}"
                }
            }
            print(json.dumps(error_response), flush=True)

if __name__ == "__main__":
    main()