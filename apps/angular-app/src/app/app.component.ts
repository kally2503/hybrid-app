import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { environment } from '../environments/environment';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dashboard">
      <h1>Hybrid App Dashboard</h1>
      <p class="env-badge">Environment: {{ env }}</p>
      <div class="cards">
        <div class="card">
          <h2>Java Service</h2>
          <p class="status" [class.up]="javaStatus === 'UP'">{{ javaStatus }}</p>
          <pre>{{ javaData | json }}</pre>
        </div>
        <div class="card">
          <h2>Python Service</h2>
          <p class="status" [class.up]="pythonStatus === 'UP'">{{ pythonStatus }}</p>
          <pre>{{ pythonData | json }}</pre>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .dashboard { max-width: 900px; margin: 40px auto; padding: 20px; }
    h1 { color: #1a1a2e; margin-bottom: 10px; }
    .env-badge { background: #16213e; color: #fff; display: inline-block; padding: 4px 12px; border-radius: 12px; margin-bottom: 20px; }
    .cards { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .status { font-weight: bold; color: #e74c3c; }
    .status.up { color: #27ae60; }
    pre { background: #f8f9fa; padding: 10px; border-radius: 4px; margin-top: 10px; font-size: 13px; overflow-x: auto; }
  `]
})
export class AppComponent implements OnInit {
  env = environment.name;
  javaStatus = 'CHECKING...';
  pythonStatus = 'CHECKING...';
  javaData: any = {};
  pythonData: any = {};

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.http.get<any>(`${environment.javaApiUrl}/api/health`).subscribe({
      next: (res) => this.javaStatus = res.status,
      error: () => this.javaStatus = 'DOWN'
    });
    this.http.get<any>(`${environment.javaApiUrl}/api/data`).subscribe({
      next: (res) => this.javaData = res,
      error: () => this.javaData = { error: 'Unable to fetch' }
    });
    this.http.get<any>(`${environment.pythonApiUrl}/api/health`).subscribe({
      next: (res) => this.pythonStatus = res.status,
      error: () => this.pythonStatus = 'DOWN'
    });
    this.http.get<any>(`${environment.pythonApiUrl}/api/data`).subscribe({
      next: (res) => this.pythonData = res,
      error: () => this.pythonData = { error: 'Unable to fetch' }
    });
  }
}
