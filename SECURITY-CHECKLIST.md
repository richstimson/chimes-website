# Security Checklist for chimesapp.com Recovery

## Immediate Actions (Do These First)

### 1. Change All Passwords
- [ ] Hosting control panel password
- [ ] FTP/SFTP credentials  
- [ ] Domain registrar password
- [ ] Email accounts associated with the domain
- [ ] Any CMS admin passwords (if applicable)

### 2. Clean Your Server
- [ ] Run the cleanup script: `./cleanup-hosting.sh`
- [ ] Verify all malicious files are removed
- [ ] Check for any remaining suspicious directories

### 3. Deploy Clean Site
- [ ] Update FTP credentials in `deploy-clean-site.sh`
- [ ] Run deployment: `./deploy-clean-site.sh` or `./deploy-via-ssh.sh`
- [ ] Test your site is working: https://chimesapp.com

## Security Hardening

### 4. File Permissions
- [ ] Set proper file permissions (644 for files, 755 for directories)
- [ ] Remove write permissions from web-accessible directories where not needed
- [ ] Create/update .htaccess file to block suspicious requests

### 5. Monitoring & Maintenance
- [ ] Set up automated daily backups
- [ ] Install security monitoring (if available through your host)
- [ ] Enable server access logs monitoring
- [ ] Schedule regular security scans

### 6. Prevention Measures
- [ ] Keep all software updated (if using CMS)
- [ ] Remove unused files, scripts, and directories
- [ ] Use strong, unique passwords for all accounts
- [ ] Enable two-factor authentication where available
- [ ] Regularly review server access logs

## Post-Recovery Verification

### 7. Testing
- [ ] Run another malware scan
- [ ] Test all website functionality
- [ ] Check that forms and email scripts work properly
- [ ] Verify SSL certificate is working
- [ ] Monitor server resources for unusual activity

### 8. Communication
- [ ] Contact hosting provider to confirm cleanup
- [ ] Request site to be un-flagged/reactivated
- [ ] Monitor search engine listings for any warnings

## Long-term Security

### 9. Regular Maintenance
- [ ] Weekly security scans
- [ ] Monthly password updates for critical accounts
- [ ] Quarterly backup verification
- [ ] Annual security audit

### 10. Documentation
- [ ] Document what happened and how it was resolved
- [ ] Keep record of all credential changes
- [ ] Maintain incident response procedures

---

## Emergency Contacts
- Hosting Provider: [Add contact info]
- Domain Registrar: [Add contact info]
- Security Service: [Add contact info if applicable]

---

**Note**: This breach likely occurred through:
- Weak/reused passwords
- Outdated software
- Compromised local machine
- Insecure file uploads

Investigate the root cause to prevent future incidents.