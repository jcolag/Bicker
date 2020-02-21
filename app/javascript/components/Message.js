import Paragraph from "./Paragraph"
import PropTypes from "prop-types"
import React from "react"

class Message extends React.Component {
  constructor (props) {
    super(props);
    this.state = {
      paragraphs: this.props.paragraphs,
      result: {},
    }
  }

  updateParagraphs(reportError, data) {
    const paragraphs = JSON.parse(data);

    this.setState({
      paragraphs: [],
    });
    this.setState({
      paragraphs: paragraphs,
    });
  }

  render () {
    const paragraphs = this.state.paragraphs.map(
      p => <Paragraph
        avatar={p.avatar}
        beenseen={p.beenseen}
        callback={this.updateParagraphs.bind(this)}
        children={p.children}
        content={p.content}
        indent={p.indent}
        key={`p-${p.id}`}
        pid={p.id}
        pnum={p.id}
        ts={p.ts}
        when={p.when}
        who={p.who}
      />
    );
    return (
      <React.Fragment>
        {paragraphs}
      </React.Fragment>
    );
  }
}

Message.propTypes = {
  paragraphs: PropTypes.array
};
export default Message
