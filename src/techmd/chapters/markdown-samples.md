# Code Sample
Some inline code `int a; a += "asd"`

```{.cpp .numberLines}
class LogicNode
{
public:
    EG_DEFINE_TYPES();

    using InputSockets  = std::vector<LogicSocketInputBase*>;
    using OutputSockets = std::vector<LogicSocketOutputBase*>;

public:
    //! The basic constructor of a node.
    LogicNode(NodeId id = nodeIdInvalid)
        : m_id(id)
    {}

    LogicNode(const LogicNode&) = default;
    LogicNode(LogicNode&&)      = default;

    virtual ~LogicNode() = default;

    //! The init function.
    virtual void init() = 0;

    //! The reset function.
    virtual void reset() = 0;

    //! The main compute function of this execution node.
    virtual void compute() = 0;

public:
    NodeId id() const { return m_id; }
    void setId(NodeId id) { m_id = id; }

protected:
    //! Registers input sockets for this node.
    template<typename... Sockets>
    void registerInputs(std::tuple<Sockets...>& sockets)
    {
        m_inputs = tupleUtil::toPointers<
            [](auto*... p) { return InputSockets{p...}; }>(sockets);
    }

    //! Registers output sockets for this node.
    template<typename... Sockets>
    void registerOutputs(std::tuple<Sockets...>& sockets)
    {
        m_outputs = tupleUtil::toPointers<
            [](auto*... p) { return OutputSockets{p...}; }>(sockets);
    }

public:
    //! Get the list of input sockets.
    const InputSockets& getInputs() const { return m_inputs; }
    InputSockets& getInputs() { return m_inputs; }

    //! Get the list of output sockets.
    const OutputSockets& getOutputs() const { return m_outputs; }
    OutputSockets& getOutputs() { return m_outputs; }

    //! Get the input socket at index `index`.
    const LogicSocketInputBase* input(SocketIndex index) const
    {
        EG_THROW_IF(index >= m_inputs.size(), "Wrong index");
        return m_inputs[index];
    }

    //! Get the input socket at index `index`.
    LogicSocketInputBase* input(SocketIndex index)
    {
        EG_THROW_IF(index >= m_inputs.size(), "Wrong index");
        return m_inputs[index];
    }

    //! Get the output socket at index `index`.
    const LogicSocketOutputBase* output(SocketIndex index) const
    {
        EG_THROW_IF(index >= m_outputs.size(), "Wrong index");
        return m_outputs[index];
    }

    //! Get the output socket at index `index`.
    LogicSocketOutputBase* output(SocketIndex index)
    {
        EG_THROW_IF(index >= m_outputs.size(), "Wrong index");
        return m_outputs[index];
    }

protected:
    NodeId m_id;              //!< The id of the node.
    InputSockets m_inputs;    //!< The input sockets.
    OutputSockets m_outputs;  //!< The output sockets.
};
```

A normal code block without syntax highlighting:

```
Some special text here. Some special text here. Some special text here. Some special text here. Some special text here. Some special text here. Some special text here. 
```

# PDF Include Sample

You can also include PDFs directly by:
Selecting pages works only in `latex` output.

![Pandoc User's Guide](files/PandocUsersGuide.pdf){.includepdf pages=5- style="width:100%;height:20cm;max-width:100%"}

# Questionaire Sample

## Personal {.unnumbered .unlisted}

- Name: []{.hrule-fill thickness=0.5pt width=10cm}
- Email: []{.hrule-fill thickness=0.5pt height=-4pt width=10cm}

## How hard is Markdown? {.unnumbered .unlisted}

- [ ] easy
- [ ] medium hard
- [ ] ridiculuous hard
  
## Which features would you like to have which Markdown does currently not support? {.unnumbered .unlisted}

[]{.hrule thickness=0.5pt width=100%} \
[]{.hrule thickness=0.5pt width=100%} \
[]{.hrule thickness=0.5pt width=100%} 
