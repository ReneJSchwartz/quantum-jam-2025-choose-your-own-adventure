# quantum_word_dictionary.py
# 🌟 COMPREHENSIVE QUANTUM WORD DICTIONARY FOR SERVER-SIDE PROCESSING
# 
# This dictionary categorizes ALL words from the "Echoes of Light" story text
# into 7 quantum transformation categories, each using real qiskit quantum circuits:
#
# BASIC TRANSFORMATIONS (using quantum_echo function):
# - SCRAMBLE: Hadamard gates + quantum measurement for randomization
# - REVERSE: X gates + controlled operations for bit flipping  
# - GHOST: Y rotation gates for subtle quantum interference
# - QUANTUM_CAPS: Mixed H and Z gates for quantum capitalization
#
# ADVANCED TRANSFORMATIONS (using dedicated quantum functions):
# - QUANTUM_GATES: Custom gate sequences (H, X, Y, Z, ROT)
# - QUANTUM_ENTANGLEMENT: Multi-qubit entanglement circuits
# - QUANTUM_MEMORY: Quantum memory fragmentation with intensity control

# 🧠 MEMORY & CONSCIOUSNESS WORDS → QUANTUM_MEMORY (Advanced)
# Words related to memory, consciousness, time, and recollection
# Uses quantum_memory endpoint with fragmentation/entanglement effects
QUANTUM_MEMORY_WORDS = {
    'memory', 'memories', 'remember', 'forgot', 'forgotten', 'recall', 'recalling',
    'past', 'history', 'lost', 'gone', 'disappeared', 'missing', 'vanished',
    'vanishing', 'fading', 'fade', 'fades', 'dim', 'silent', 'silence',
    'trace', 'traces', 'hidden', 'buried', 'pulled', 'back', 'echo', 'echoes',
    'whisper', 'whispers', 'murmur', 'murmurs', 'voices', 'voice', 'messages',
    'beneath', 'surface', 'faint', 'fragile', 'fragments', 'fragment',
    'extinguished', 'beckons', 'listen', 'gather', 'gathered', 'knowledge',
    'remembered', 'partially', 'dreams', 'despair', 'limbo', 'waiting',
    'remembrance', 'boundary', 'oblivion', 'once', 'might', 'been',
    'intertwined', 'webs', 'consciousness', 'awareness', 'mind', 'thought',
    'thoughts', 'forgotten', 'afterglow', 'moments', 'moment', 'resurrect',
    'resurrection', 'revival', 'revive', 'reclaim', 'reclaiming', 'reshape',
    'reshaping', 'data', 'information', 'trapped', 'stored', 'imprint'
}

# 👻 QUANTUM & SCIENTIFIC PHENOMENA → GHOST (Basic)
# Words related to quantum physics, light, energy, and scientific phenomena
# Uses quantum_echo with Y rotation gates for spectral effects
GHOST_WORDS = {
    'quantum', 'light', 'burst', 'bursts', 'brilliant', 'glow', 'glowing',
    'flickering', 'flicker', 'faintly', 'slowly', 'leaving', 'pulse',
    'pulses', 'pulsing', 'signal', 'signals', 'energy', 'wave', 'waves',
    'particle', 'particles', 'field', 'fields', 'resonance', 'frequency',
    'frequencies', 'interference', 'superposition', 'entanglement', 'coherence',
    'decoherence', 'collapse', 'measurement', 'measurements', 'circuit',
    'circuits', 'gate', 'gates', 'operation', 'operations', 'effect',
    'effects', 'phenomenon', 'phenomena', 'superconductor', 'superconductors',
    'superconducting', 'higgs', 'signature', 'signatures', 'state', 'states',
    'amplitudes', 'amplitude', 'qubits', 'qubit', 'feedback', 'fractures',
    'fracture', 'reality', 'realities', 'timelines', 'timeline', 'parallel',
    'alternate', 'dimension', 'dimensions', 'space', 'time', 'continuum',
    'echo-tech', 'processor', 'computing', 'technology', 'beam', 'beams',
    'ray', 'rays', 'emission', 'spectrum', 'wavelength', 'photon', 'photons'
}

# 🤖 TECHNOLOGY & AI SYSTEMS → QUANTUM_CAPS (Basic)
# Words related to technology, AI, computing, and technical systems
# Uses quantum_echo with mixed H and Z gates for technical emphasis
QUANTUM_CAPS_WORDS = {
    'novacore', 'ava', 'ai', 'assistant', 'system', 'systems', 'processing',
    'processor', 'neural', 'digital', 'computer', 'computers', 'computing',
    'analysis', 'analyze', 'calculation', 'calculate', 'protocol', 'protocols',
    'interface', 'interfaces', 'network', 'networks', 'diagnostic', 'diagnostics',
    'error', 'errors', 'warning', 'warnings', 'stable', 'stability', 'unstable',
    'crash', 'crashes', 'crashed', 'instruments', 'instrument', 'register',
    'registers', 'capture', 'captured', 'equipment', 'console', 'consoles',
    'lab', 'laboratory', 'experiment', 'experiments', 'experimenting',
    'secure', 'security', 'doors', 'scientists', 'scientist', 'catalog',
    'cataloging', 'excited', 'massive', 'holograms', 'hologram', 'technical',
    'achievement', 'achievements', 'barriers', 'barrier', 'surpassed',
    'monumental', 'stabilize', 'stabilizing', 'sensor', 'sensors', 'precise',
    'precision', 'timing', 'unpredictable', 'device', 'devices', 'machine',
    'machines', 'machinery', 'apparatus', 'control', 'controls', 'controlled',
    'monitor', 'monitoring', 'display', 'displays', 'screen', 'screens'
}

# 🔬 ADVANCED QUANTUM OPERATIONS → QUANTUM_GATES (Advanced)  
# Words related to complex quantum operations and gate sequences
# Uses quantum_gates endpoint with custom H-X-Y-Z-ROT sequences
QUANTUM_GATES_WORDS = {
    'bit_flip', 'phase_flip', 'rotate', 'rotation', 'hadamard', 'pauli',
    'unitary', 'matrix', 'matrices', 'eigenvalue', 'eigenvector', 'basis',
    'computational', 'transform', 'transformation', 'transformations',
    'sequence', 'sequences', 'apply', 'applied', 'applying', 'gate',
    'gates', 'operation', 'operations', 'quantum', 'circuit', 'circuits',
    'algorithm', 'algorithms', 'complexity', 'optimization', 'optimization',
    'encode', 'encoding', 'decode', 'decoding', 'process', 'processes',
    'processing', 'manipulation', 'manipulate', 'manipulating', 'control',
    'controlled', 'precision', 'accurate', 'calibrate', 'calibration',
    'fine-tune', 'adjustment', 'parameters', 'parameter', 'variables',
    'variable', 'function', 'functions', 'execute', 'execution', 'run',
    'simulate', 'simulation', 'model', 'modeling', 'calculate', 'computation'
}

# ⚡ ENTANGLEMENT & CORRELATION → QUANTUM_ENTANGLEMENT (Advanced)
# Words related to connections, relationships, and correlated phenomena  
# Uses quantum_entanglement endpoint with multi-qubit entanglement circuits
QUANTUM_ENTANGLEMENT_WORDS = {
    'connection', 'connections', 'connected', 'linking', 'linked', 'bind',
    'binding', 'bound', 'together', 'paired', 'pairs', 'correlation',
    'correlations', 'correlated', 'relationship', 'relationships', 'bond',
    'bonds', 'bonding', 'sync', 'synchronized', 'harmony', 'harmonized',
    'unified', 'unite', 'unity', 'merge', 'merged', 'merging', 'combine',
    'combined', 'combining', 'intertwined', 'entangled', 'entanglement',
    'coupled', 'coupling', 'shared', 'sharing', 'communicate', 'communication',
    'communicating', 'telepathic', 'instant', 'instantaneous', 'simultaneous',
    'across', 'between', 'among', 'throughout', 'network', 'web', 'matrix',
    'fabric', 'threads', 'thread', 'woven', 'weaving', 'pattern', 'patterns',
    'resonant', 'resonating', 'vibration', 'vibrations', 'frequency', 'tune',
    'tuned', 'attuned', 'alignment', 'aligned', 'coherent', 'coherence',
    'interference', 'constructive', 'destructive', 'phase', 'phases'
}

# 💥 EMOTIONAL & DRAMATIC TENSION → SCRAMBLE (Basic)
# Words conveying emotion, tension, drama, and intense moments
# Uses quantum_echo with Hadamard gates for dramatic randomization
SCRAMBLE_WORDS = {
    'tension', 'tense', 'etched', 'face', 'faces', 'panicked', 'panic',
    'run', 'running', 'swallowed', 'blink', 'blinking', 'fear', 'fears',
    'afraid', 'scared', 'breathing', 'breathe', 'down', 'neck', 'pressure',
    'locked', 'lock', 'away', 'behind', 'heavy', 'doors', 'trapped',
    'hard', 'difficult', 'struggle', 'struggling', 'managed', 'manage',
    'finally', 'at_last', 'today', 'need', 'needs', 'right', 'correct',
    'choose', 'choice', 'choices', 'decision', 'decisions', 'steady',
    'hands', 'hand', 'initiate', 'start', 'begin', 'fails', 'fail',
    'failure', 'vanishes', 'vanish', 'ghost', 'ghosts', 'ghostly',
    'realities', 'strong', 'strength', 'enough', 'sufficient', 'caution',
    'careful', 'best', 'optimal', 'critical', 'crash', 'crashes',
    'entire', 'whole', 'complete', 'fixing', 'fix', 'repair', 'risk',
    'risks', 'risky', 'dangerous', 'anyway', 'regardless', 'unstable',
    'proceed', 'continue', 'forward', 'dreams', 'dream', 'nightmare',
    'despair', 'hopeless', 'melancholy', 'sad', 'sadness', 'seeps',
    'deep', 'profound', 'testament', 'witness', 'limbo', 'stuck',
    'fragile', 'delicate', 'nature', 'essence', 'blurs', 'blur',
    'confused', 'awed', 'amazed', 'complex', 'complicated', 'emerge',
    'emerging', 'multiple', 'many', 'several', 'branching', 'branch',
    'possibilities', 'possible', 'hearts', 'heart', 'pounding', 'beat',
    'anticipation', 'anticipate', 'waiting', 'whispered', 'whisper',
    'across', 'space', 'distance', 'proof', 'evidence', 'beginning',
    'start', 'commence', 'urgent', 'urgency', 'immediate', 'crisis',
    'emergency', 'alarm', 'warning', 'threat', 'danger', 'perilous'
}

# 🌀 COMMON STORY WORDS → REVERSE (Basic)
# High-frequency words that appear throughout the narrative
# Uses quantum_echo with X gates and controlled operations for case reversal
REVERSE_WORDS = {
    'that', 'was', 'three', 'days', 'ago', 'and', 'you', 'theo', 'have',
    'been', 'the', 'are', 'will', 'can', 'this', 'with', 'your', 'but',
    'for', 'not', 'all', 'any', 'had', 'her', 'his', 'how', 'its', 'may',
    'new', 'old', 'see', 'two', 'who', 'did', 'has', 'let', 'put', 'say',
    'she', 'too', 'use', 'here', 'there', 'where', 'when', 'why', 'what',
    'which', 'each', 'than', 'them', 'these', 'those', 'would', 'could',
    'should', 'their', 'they', 'we', 'our', 'us', 'him', 'if', 'or',
    'as', 'at', 'be', 'by', 'do', 'go', 'he', 'i', 'in', 'is', 'it',
    'me', 'my', 'no', 'of', 'on', 'so', 'to', 'up', 'an', 'am', 'one',
    'first', 'last', 'next', 'then', 'now', 'before', 'after', 'during',
    'while', 'until', 'since', 'from', 'into', 'onto', 'upon', 'over',
    'under', 'through', 'around', 'between', 'among', 'within', 'without',
    'about', 'above', 'below', 'near', 'far', 'left', 'right', 'front',
    'back', 'side', 'top', 'bottom', 'inside', 'outside', 'around',
    'towards', 'away', 'against', 'along', 'across', 'beyond', 'behind',
    'beside', 'beneath', 'above', 'below', 'off', 'out', 'down', 'forward'
}

# 🎯 QUANTUM WORD CATEGORIZER FUNCTION
def get_quantum_category_for_word(word):
    """
    Determine which quantum transformation category a word belongs to.
    
    Args:
        word (str): Input word to categorize
    
    Returns:
        str: Quantum transformation type ('scramble', 'reverse', 'ghost', 'quantum_caps', 
             'quantum_gates', 'quantum_entanglement', 'quantum_memory', or 'original')
    """
    word_lower = word.lower().strip()
    
    # Check categories in priority order (most specific first)
    if word_lower in QUANTUM_MEMORY_WORDS:
        return 'quantum_interference'
    elif word_lower in QUANTUM_GATES_WORDS:
        return 'quantum_gates'
    elif word_lower in QUANTUM_ENTANGLEMENT_WORDS:
        return 'quantum_entanglement'
    elif word_lower in GHOST_WORDS:
        return 'ghost'
    elif word_lower in QUANTUM_CAPS_WORDS:
        return 'quantum_caps'
    elif word_lower in SCRAMBLE_WORDS:
        return 'scramble'
    elif word_lower in REVERSE_WORDS:
        return 'reverse'
    else:
        return 'original'  # No quantum transformation

# 📊 STATISTICS AND COVERAGE FUNCTIONS
def get_all_quantum_words():
    """Get all words that will receive quantum transformations."""
    return (QUANTUM_MEMORY_WORDS | QUANTUM_GATES_WORDS | QUANTUM_ENTANGLEMENT_WORDS | 
            GHOST_WORDS | QUANTUM_CAPS_WORDS | SCRAMBLE_WORDS | REVERSE_WORDS)

def get_category_stats():
    """Get statistics about word distribution across categories."""
    return {
        'quantum_memory': len(QUANTUM_MEMORY_WORDS),
        'quantum_gates': len(QUANTUM_GATES_WORDS), 
        'quantum_entanglement': len(QUANTUM_ENTANGLEMENT_WORDS),
        'ghost': len(GHOST_WORDS),
        'quantum_caps': len(QUANTUM_CAPS_WORDS),
        'scramble': len(SCRAMBLE_WORDS),
        'reverse': len(REVERSE_WORDS),
        'total_quantum_words': len(get_all_quantum_words())
    }

def analyze_text_coverage(text):
    """
    Analyze what percentage of words in a text will get quantum transformations.
    
    Args:
        text (str): Input text to analyze
    
    Returns:
        dict: Coverage statistics and word categorization
    """
    import re
    words = re.findall(r'\b\w+\b', text.lower())
    
    categorized_words = {
        'quantum_memory': [],
        'quantum_gates': [],
        'quantum_entanglement': [],
        'ghost': [],
        'quantum_caps': [],
        'scramble': [],
        'reverse': [],
        'original': []
    }
    
    for word in words:
        category = get_quantum_category_for_word(word)
        categorized_words[category].append(word)
    
    total_words = len(words)
    quantum_words = total_words - len(categorized_words['original'])
    coverage_percent = (quantum_words / total_words * 100) if total_words > 0 else 0
    
    return {
        'total_words': total_words,
        'quantum_words': quantum_words,
        'coverage_percent': round(coverage_percent, 1),
        'categorized_words': categorized_words,
        'category_counts': {cat: len(words) for cat, words in categorized_words.items()}
    }

# 🚀 EXAMPLE USAGE
if __name__ == "__main__":
    # Test with sample text from your story
    sample_text = """That was three days ago and you, Theo and Ava have been locked away behind heavy security doors in the secure lab working hard. But today — you have finally managed to recreate the original experiment. You stand before the quantum echo lab console, the vanished burst of light now flickering faintly on the screen."""
    
    print("🧪 QUANTUM WORD DICTIONARY TEST")
    print("=" * 50)
    
    # Analyze coverage
    analysis = analyze_text_coverage(sample_text)
    print(f"📊 Coverage Analysis:")
    print(f"   Total words: {analysis['total_words']}")
    print(f"   Quantum words: {analysis['quantum_words']}")
    print(f"   Coverage: {analysis['coverage_percent']}%")
    print()
    
    # Show category distribution
    print("🎭 Category Distribution:")
    for category, count in analysis['category_counts'].items():
        if count > 0:
            print(f"   {category}: {count} words")
    print()
    
    # Show dictionary statistics
    stats = get_category_stats()
    print("📚 Dictionary Statistics:")
    for category, count in stats.items():
        print(f"   {category}: {count} words")
