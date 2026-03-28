const dataCache = new Map<string, unknown>();

export async function loadData<T = unknown>(path: string): Promise<T> {
  if (dataCache.has(path)) {
    return dataCache.get(path) as T;
  }

  const response = await fetch(`/data/${path}.json`);
  if (!response.ok) {
    throw new Error(
      `Failed to load data: /data/${path}.json (${response.status})`,
    );
  }

  const data = await response.json();
  dataCache.set(path, data);
  return data as T;
}

export function clearDataCache(): void {
  dataCache.clear();
}
