const Project = require('../models/project.model');
const cloudinary = require('../config/cloudinary');

exports.createProject = async (req, res) => {
  try {
    const project = new Project(req.body);
    await project.save();
    res.status(201).json({ success: true, project });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.getProjects = async (req, res) => {
  try {
    const projects = await Project.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, projects });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.getFeaturedProject = async (req, res) => {
  try {
    const project = await Project.findOne({ isFeatured: true, status: 'Active' }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, project });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.updateProject = async (req, res) => {
  try {
    const project = await Project.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!project) return res.status(404).json({ success: false, error: 'Project not found' });
    res.status(200).json({ success: true, project });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.deleteProject = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) return res.status(404).json({ success: false, error: 'Project not found' });

    if (project.cloudinaryPublicId) {
      await cloudinary.uploader.destroy(project.cloudinaryPublicId);
    }
    await project.deleteOne();
    res.status(200).json({ success: true, message: 'Project deleted' });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};
