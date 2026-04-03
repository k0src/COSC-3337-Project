import { useState, useEffect, useRef } from "react";
import { loadData } from "@lib";

interface UseDataResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

export function useData<T = unknown>(path: string): UseDataResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const prevData = useRef<T | null>(null);

  useEffect(() => {
    let cancelled = false;

    setLoading(true);
    setError(null);

    loadData<T>(path)
      .then((result) => {
        if (!cancelled) {
          prevData.current = result;
          setData(result);
          setLoading(false);
        }
      })
      .catch((err) => {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Failed to load data");
          setLoading(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [path]);

  // Return previous data while loading to prevent layout collapse
  return { data: data ?? prevData.current, loading, error };
}
