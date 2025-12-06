/**
 * API Client for OC System
 * Handles all API requests with JWT authentication
 */

class ApiClient {
    constructor(baseUrl = '/api') {
        this.baseUrl = baseUrl;
    }

    /**
     * Get JWT token from cookie
     */
    async getToken() {
        const response = await fetch('/api/jwt-token');
        const data = await response.json();
        return data.token;
    }

    /**
     * Make API request
     */
    async request(endpoint, options = {}) {
        const token = await this.getToken();
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${token}`,
            ...options.headers,
        };

        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        const config = {
            ...options,
            headers,
        };

        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`, config);
            
            if (response.status === 401) {
                // Unauthorized - redirect to login
                window.location.href = '/login';
                return null;
            }

            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'API request failed');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // Auth endpoints
    async getMe() {
        return this.request('/me');
    }

    async logout() {
        return this.request('/logout', { method: 'POST' });
    }

    // Project endpoints
    async getProjects() {
        return this.request('/projects');
    }

    async getProject(projectId) {
        return this.request(`/projects/${projectId}`);
    }

    async createProject(data) {
        return this.request('/projects', {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateProject(projectId, data) {
        return this.request(`/projects/${projectId}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async deleteProject(projectId) {
        return this.request(`/projects/${projectId}`, {
            method: 'DELETE',
        });
    }

    // Task endpoints
    async getTasks(projectId) {
        return this.request(`/projects/${projectId}/tasks`);
    }

    async getTasksKanban(projectId) {
        return this.request(`/projects/${projectId}/tasks/kanban`);
    }

    async getTask(projectId, taskId) {
        return this.request(`/projects/${projectId}/tasks/${taskId}`);
    }

    async createTask(projectId, data) {
        return this.request(`/projects/${projectId}/tasks`, {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateTask(projectId, taskId, data) {
        return this.request(`/projects/${projectId}/tasks/${taskId}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async deleteTask(projectId, taskId) {
        return this.request(`/projects/${projectId}/tasks/${taskId}`, {
            method: 'DELETE',
        });
    }

    // Chat endpoints
    async getLatestProjectMessage(projectId) {
        return this.request(`/projects/${projectId}/chat`);
    }

    async getLatestPrivateMessage(projectId, otherUserId) {
        return this.request(`/projects/${projectId}/chat-private/${otherUserId}`);
    }

    async getProjectMessages(projectId, offset = 0, limit = 30) {
        return this.request(`/projects/${projectId}/chat/messages?offset=${offset}&limit=${limit}`);
    }

    async getPrivateMessages(projectId, otherUserId, offset = 0, limit = 30) {
        return this.request(`/projects/${projectId}/chat-private/${otherUserId}/messages?offset=${offset}&limit=${limit}`);
    }

    async sendProjectMessage(projectId, message = '', contentId = null) {
        return this.request(`/projects/${projectId}/chat`, {
            method: 'POST',
            body: JSON.stringify({ message: message, content_id: contentId }),
        });
    }

    async sendPrivateMessage(projectId, otherUserId, message = '', contentId = null) {
        return this.request(`/projects/${projectId}/chat-private/${otherUserId}`, {
            method: 'POST',
            body: JSON.stringify({ message: message, content_id: contentId }),
        });
    }

    async markAsRead(messageId) {
        return this.request(`/mark-as-read/${messageId}`, {
            method: 'POST',
        });
    }

    async getPinMessage(projectId, otherUserId = null) {
        if(otherUserId) {
            return this.request(`/projects/${projectId}/chat-private/${otherUserId}/pin`);
        } else {
            return this.request(`/projects/${projectId}/chat/pin`);
        }
    }

    async pinMessage(messageId) {
        return this.request(`/message/${messageId}/pin`, {
            method: 'POST',
        });
    }

    async unpinMessage(messageId) {
        return this.request(`/message/${messageId}/unpin`, {
            method: 'POST',
        });
    }

    async searchMessages(projectId, query, otherUserId = null) {
        return this.request(`/projects/${projectId}/chat-search?query=${query}&other_user_id=${otherUserId}`);
    }

    // Resource endpoints
    async getProjectResources(projectId) {
        return this.request(`/projects/${projectId}/resources`);
    }

    async getTaskResources(projectId, taskId) {
        return this.request(`/projects/${projectId}/tasks/${taskId}/resources`);
    }

    async uploadFile(file, contentType, taskId = null) {
        const formData = new FormData();
        formData.append('file', file);

        const token = await this.getToken();
        const headers = {
            'Accept': 'application/json',
        };

        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        const response = await fetch(`${this.baseUrl}/resources/upload?content_type=${contentType}&task_id=${taskId}`, {
            method: 'POST',
            headers,
            body: formData,
        });

        return response.json();
    }

    async deleteResource(resourceId) {
        return this.request(`/resources/${resourceId}`, {
            method: 'DELETE',
        });
    }

    // Member endpoints
    async getProjectMembers(projectId) {
        return this.request(`/projects/${projectId}/members`);
    }

    async addProjectMember(projectId, memberId, role) {
        return this.request(`/projects/${projectId}/members`, {
            method: 'POST',
            body: JSON.stringify({ member_id: memberId, role: role }),
        });
    }

    async removeProjectMember(projectId, memberId) {
        return this.request(`/projects/${projectId}/members/${memberId}`, {
            method: 'DELETE',
        });
    }

    async updateMemberRole(projectId, memberId, role) {
        return this.request(`/projects/${projectId}/members/${memberId}/role/${role}`, {
            method: 'PUT',
        });
    }
}

// Create global instance
window.api = new ApiClient();

