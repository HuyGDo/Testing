const express = require('express');

class SseService {
  constructor() {
    this.clients = {}; // Store clients by vm_id
  }

  addClient(req, res, vm_id) {
    const headers = {
      'Content-Type': 'text/event-stream',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache'
    };
    res.writeHead(200, headers);
    res.write('data: {"message": "connected"}\n\n');

    const clientId = Date.now();
    const newClient = { id: clientId, res };
    
    if (!this.clients[vm_id]) {
      this.clients[vm_id] = [];
    }
    this.clients[vm_id].push(newClient);
    console.log(`SSE client ${clientId} connected for vm_id: ${vm_id}`);

    req.on('close', () => {
      this.removeClient(clientId, vm_id);
    });
  }

  removeClient(clientId, vm_id) {
    if (this.clients[vm_id]) {
      this.clients[vm_id] = this.clients[vm_id].filter(client => client.id !== clientId);
      if (this.clients[vm_id].length === 0) {
        delete this.clients[vm_id];
      }
      console.log(`SSE client ${clientId} disconnected for vm_id: ${vm_id}`);
    }
  }

  send(vm_id, data) {
    const clients = this.clients[vm_id] || [];
    clients.forEach(client => {
      client.res.write(`data: ${JSON.stringify(data)}\n\n`);
    });
  }
}

const sseService = new SseService();
module.exports = sseService; 