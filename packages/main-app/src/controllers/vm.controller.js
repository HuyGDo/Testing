const vmService = require('../services/vm.service');

async function createVm(req, res) {
    try {
        const vm = await vmService.createVm(req.body);
        res.status(201).json(vm);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error creating VM' });
    }
}

async function getAllVms(req, res) {
    try {
        const vms = await vmService.getAllVms();
        res.status(200).json(vms);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching VMs' });
    }
}

async function deleteVm(req, res) {
    try {
        const { id } = req.params;
        await vmService.deleteVm(id);
        res.status(204).send();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error deleting VM' });
    }
}

module.exports = {
    createVm,
    getAllVms,
    deleteVm
};
