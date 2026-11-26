function sfx_play(kind)
% SFX_PLAY  Procedural sound effects using base MATLAB only (no audio files).
    try
        Fs = 16000;
        switch kind
            case 'correct'
                % Warm golden temple chime (C5 -> E5 -> G5 -> C6)
                t = (0:round(0.55*Fs)) / Fs;
                freqs = [523.25, 659.25, 783.99, 1046.50];
                y = zeros(size(t));
                for k = 1:4
                    t0 = (k - 1) * 0.07;
                    env = exp(-6.5 * max(0, t - t0)) .* (t >= t0);
                    y = y + 0.22 * env .* sin(2 * pi * freqs(k) * (t - t0));
                end
            case 'wrong'
                % Low stone thud
                t = (0:round(0.28*Fs)) / Fs;
                f = 135 - 55 * (t / max(t));
                y = 0.45 * exp(-10 * t) .* sin(2 * pi * f .* t);
            case 'gate'
                % Deep grinding stone rumble
                t = (0:round(1.4*Fs)) / Fs;
                raw = randn(size(t));
                rumble = conv(raw, ones(1, 35) / 35, 'same');
                env = sin(pi * t / max(t)).^0.6;
                y = 0.55 * env .* (rumble / max(abs(rumble) + eps));
            case 'transition'
                % Mystical rising portal shimmer
                t = (0:round(0.85*Fs)) / Fs;
                f = 220 + 440 * (t / max(t)).^1.5;
                env = sin(pi * t / max(t));
                y = 0.30 * env .* (sin(2*pi*f.*t) + 0.5*sin(4*pi*f.*t));
            otherwise
                return;
        end
        sound(max(-0.95, min(0.95, y)), Fs);
    catch
        % Silently skip if no audio device is available
    end
end