"use client";

import { useState, useEffect } from 'react';
import useSWR, { mutate } from 'swr';
import { getVMs, addVM, deleteVM, VM } from '@/api';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

const VMS_KEY = '/vms';

export default function VmsPage() {
  const { data: vms, error, isLoading } = useSWR<VM[]>(VMS_KEY, getVMs);
  const [isAddVmDialogOpen, setAddVmDialogOpen] = useState(false);
  const [newVmName, setNewVmName] = useState('');
  const [newVmIpAddress, setNewVmIpAddress] = useState('');

  const handleAddVm = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await addVM({ name: newVmName, ip_address: newVmIpAddress });
      mutate(VMS_KEY);
      setNewVmName('');
      setNewVmIpAddress('');
      setAddVmDialogOpen(false);
    } catch (error) {
      console.error('Failed to add VM', error);
      // Here you could show an error to the user
    }
  };

  const handleDeleteVm = async (id: string) => {
    try {
      await deleteVM(id);
      mutate(VMS_KEY);
    } catch (error) {
      console.error('Failed to delete VM', error);
      // Here you could show an error to the user
    }
  };

  if (error) return <div>Failed to load VMs</div>;
  if (isLoading) return <div>Loading...</div>;

  return (
    <div className="container mx-auto py-10">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">VM Management</h1>
        <Dialog open={isAddVmDialogOpen} onOpenChange={setAddVmDialogOpen}>
          <DialogTrigger asChild>
            <Button>Add VM</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add a new VM</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleAddVm} className="grid gap-4 py-4">
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="name" className="text-right">
                  Name
                </Label>
                <Input
                  id="name"
                  value={newVmName}
                  onChange={(e) => setNewVmName(e.target.value)}
                  className="col-span-3"
                  required
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="ip_address" className="text-right">
                  IP Address
                </Label>
                <Input
                  id="ip_address"
                  value={newVmIpAddress}
                  onChange={(e) => setNewVmIpAddress(e.target.value)}
                  className="col-span-3"
                  required
                />
              </div>
              <Button type="submit">Add VM</Button>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>IP Address</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {vms?.map((vm) => (
            <TableRow key={vm.id}>
              <TableCell>{vm.name}</TableCell>
              <TableCell>{vm.ip_address}</TableCell>
              <TableCell>{vm.status}</TableCell>
              <TableCell>
                <Button variant="destructive" size="sm" onClick={() => handleDeleteVm(vm.id)}>
                  Delete
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
