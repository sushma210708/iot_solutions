const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

const User = require('./src/models/user.model');

mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    console.log('MongoDB Connected.');
    const users = await User.find({ role: 'user' });
    console.log('Registered Users found:', users.length);
    if (users.length > 0) {
      console.log(users);
    } else {
        const allUsers = await User.find({});
        console.log('Total users in DB:', allUsers.length);
        allUsers.forEach(u => console.log(`- ${u.email} (Role: ${u.role})`));
    }
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err);
    process.exit(1);
  });
