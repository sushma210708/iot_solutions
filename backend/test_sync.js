const mongoose = require('mongoose');
const User = require('./src/models/user.model');

async function run() {
  await mongoose.connect('mongodb+srv://s210708891_db_user:sush210708@cluster0.ojuusyh.mongodb.net/greenfusion?retryWrites=true&w=majority&appName=Cluster0');
  
  const testEmail = 'newadmintest88@test.com';
  
  await User.deleteOne({ email: testEmail });
  
  const admin = await User.create({
    name: 'Sync Test Admin',
    email: testEmail,
    firebaseUid: testEmail, 
    role: 'content_admin',
    status: 'active'
  });
  
  console.log('Created admin:', admin);
  process.exit(0);
}
run();
