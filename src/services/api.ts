/**
 * API Service for ReproLab
 * Handles communication with the backend server extension
 */

import { requestServer } from './server';

export interface ApiResponse<T = any> {
  status: 'success' | 'error';
  message: string;
  data?: T;
  path?: string;
}

export interface ExperimentData {
  name?: string;
  description?: string;
  notebook_path?: string;
  action?: 'start' | 'end';
}

export interface EnvironmentData {
  action: 'create_environment' | 'freeze_dependencies';
  venv_name?: string;
}

export interface ArchiveData {
  name?: string;
  include_data?: boolean;
  include_notebooks?: boolean;
  tag_name?: string;
}

export interface ZenodoData {
  title?: string;
  description?: string;
  authors?: string[];
  tag_name?: string;
}

class ApiService {
  private async makeRequest<T>(
    endpoint: string,
    method: 'GET' | 'POST' = 'GET',
    data?: any
  ): Promise<ApiResponse<T>> {
    endpoint = `reprolab/api/${endpoint}`;

    const options: RequestInit = {
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (data && method === 'POST') {
      options.body = JSON.stringify(data);
    }

    try {
      console.log('[ReproLab API] Making request to:', endpoint);
      console.log('[ReproLab API] Headers:', options.headers);
      const { data } = await requestServer<ApiResponse<T>>(endpoint, options);
      return data;
    } catch (error) {
      console.error(`API request failed for ${endpoint}:`, error);
      throw error;
    }
  }

  /**
   * Check if the server extension is running
   */
  async checkStatus(): Promise<ApiResponse> {
    return this.makeRequest('status');
  }

  /**
   * Create a new experiment
   */
  async createExperiment(data: ExperimentData): Promise<ApiResponse> {
    return this.makeRequest('experiment', 'POST', data);
  }

  /**
   * Perform environment-related actions
   */
  async performEnvironmentAction(data: EnvironmentData): Promise<ApiResponse> {
    return this.makeRequest('environment', 'POST', data);
  }

  /**
   * Create an archive package
   */
  async createArchive(data: ArchiveData): Promise<ApiResponse> {
    return this.makeRequest('archive', 'POST', data);
  }

  /**
   * Create a Zenodo-ready package
   */
  async createZenodoPackage(data: ZenodoData): Promise<ApiResponse> {
    return this.makeRequest('zenodo', 'POST', data);
  }
}

// Export a singleton instance
export const apiService = new ApiService(); 
